
import secrets
from pathlib import Path
from cryptography.hazmat.decrepit.ciphers.algorithms import ARC4
from cryptography.hazmat.primitives.ciphers import Cipher


def write_hex(filename: str, data: bytes) -> None:
    Path(filename).write_text("".join(f"{byte:02x}\n" for byte in data))

def main() -> None:
    plaintext = input("Plaintext: ").encode("utf-8")
    if not 1 <= len(plaintext) <= 255:
        raise ValueError("Plaintext must be 1 to 255 UTF-8 bytes long")

    key = secrets.token_bytes(16)
    encryptor = Cipher(ARC4(key), mode=None).encryptor()
    ciphertext = encryptor.update(plaintext) + encryptor.finalize()

    write_hex("key.mem", key)
    write_hex("plaintext.mem", plaintext)
    write_hex("ciphertext.mem", ciphertext)
    write_hex("metadata.mem", bytes([len(key), len(plaintext)]))
    print(f"Wrote four .mem files (key: {len(key)} bytes; message: {len(plaintext)} bytes)")

if __name__ == "__main__":
    main()
