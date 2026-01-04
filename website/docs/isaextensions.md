Specifies a list of supported instruction set architecture extensions.

```lua
isaextensions { "values" }
```

### Parameters ###

`values` is one of:

| Value | Description |
|-------|-------------|
| `MOVBE` | Move after byte-swap instruction (transfers data with endianness conversion) |
| `POPCNT` | Population count instruction (counts set bits in a register) |
| `PCLMUL` | Carry-less multiply instruction (PCLMULQDQ) for polynomial multiplication |
| `LZCNT` | Count leading zeros instruction (returns number of leading zero bits) |
| `BMI` | Bit Manipulation Instruction set 1 (bit-field and bit-test helpers like ANDN, BLSI) |
| `BMI2` | Bit Manipulation Instruction set 2 (advanced bit ops like MULX, PDEP, PEXT) |
| `F16C` | Half-precision floating-point conversion instructions (float16 <-> float32) |
| `AES` | AES-NI instructions for hardware-accelerated AES encryption/decryption |
| `FMA` | Fused multiply-add instructions (FMA3: 3-operand fused multiply-add) |
| `FMA4` | AMD 4-operand fused multiply-add instruction set (FMA4) |
| `RDRND` | Hardware random number generator instruction (RDRAND) |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later.

### Examples ###

```lua
isaextensions {
    "POPCNT",
    "BMI2"
}
```

