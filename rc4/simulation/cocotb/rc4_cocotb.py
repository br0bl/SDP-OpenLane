import secrets
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cryptography.hazmat.decrepit.ciphers.algorithms import ARC4
from cryptography.hazmat.primitives.ciphers import Cipher


def generate_vectors(message):
    # Generate plaintext
    plaintext = message.encode("utf-8")
    assert 1 <= len(plaintext) <= 255, "Plaintext must be 1 to 255 UTF-8 bytes"

    # Generate a random 16-byte key and reference ciphertext in memory.
    key = secrets.token_bytes(16)
    encryptor = Cipher(ARC4(key), mode=None).encryptor()
    expected = encryptor.update(plaintext) + encryptor.finalize()

    return key, plaintext, expected


async def reset_dut(dut):
    dut.CLK_IN.value = 0
    dut.RESET_N_IN.value = 0
    dut.KEY_SIZE_IN.value = 0
    dut.KEY_BYTE_IN.value = 0
    dut.PLAIN_BYTE_IN.value = 0
    dut.START_IN.value = 0
    dut.STOP_IN.value = 0
    dut.HOLD_IN.value = 0

    await RisingEdge(dut.CLK_IN)
    await FallingEdge(dut.CLK_IN)
    dut.RESET_N_IN.value = 1


async def run_encryption(dut, key, plaintext):
    key_size = len(key)
    plaintext_size = len(plaintext)
    dut.KEY_SIZE_IN.value = key_size

    dut.START_IN.value = 1
    await FallingEdge(dut.CLK_IN)
    dut.START_IN.value = 0

    key_counter = 0
    plain_counter = 0
    sending_key = False
    sending = False
    drive_valid = False
    dut_valid = False
    captured = []

    for _ in range(10000):
        await RisingEdge(dut.CLK_IN)

        request_key = int(dut.START_KEY_CPY_OUT.value)
        request_plaintext = int(dut.READ_PLAINTEXT_OUT.value)

        if dut_valid:
            captured.append(int(dut.ENC_BYTE_OUT.value))

        if len(captured) == plaintext_size:
            break

        dut_valid = drive_valid
        drive_valid = False
        key_byte = 0

        if request_key or sending_key:
            key_byte = key[key_counter]
            key_counter += 1
            sending_key = key_counter < key_size

        if (request_plaintext or sending) and plain_counter < plaintext_size:
            plain_byte = plaintext[plain_counter]
            plain_counter += 1
            drive_valid = True
            sending = plain_counter < plaintext_size

        await Timer(1, unit="ns")
        dut.KEY_BYTE_IN.value = key_byte
        if drive_valid:
            dut.PLAIN_BYTE_IN.value = plain_byte
    else:
        assert False, f"Timeout: received {len(captured)}/{plaintext_size} bytes"

    return bytes(captured)


def check_ciphertext(captured, expected):
    assert len(captured) == len(expected), "Ciphertext length mismatch"
    for index, actual in enumerate(captured):
        assert actual == expected[index], (
            f"Byte {index}: expected 0x{expected[index]:02X}, "
            f"received 0x{actual:02X}"
        )



@cocotb.test()
async def test_rc4(dut):
    # Change this message to choose the plaintext for the test.
    key, plaintext, expected = generate_vectors("Hello, RC4!")
    dut._log.info("Key: %s", key.hex())
    dut._log.info("Plaintext: %s", plaintext.hex())

    cocotb.start_soon(Clock(dut.CLK_IN, 4, unit="ns").start(start_high=False))

    await reset_dut(dut)
    captured = await run_encryption(dut, key, plaintext)
    check_ciphertext(captured, expected)

    dut._log.info("Test passed: all %d ciphertext bytes match", len(plaintext))