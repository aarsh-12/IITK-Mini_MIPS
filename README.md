**CS220 Assignment 8 Report**

  **Aarsh Jain 230015**

**Brinda Fadadu	230307**

# **PDS1: Decide the registers and their usage protocol.**

We have decided to implement **32 registers**, each one of which is **32 bits wide**. All the registers are used as storage registers except the last register, which is used for **“ra”**. We have used register symbols same as used in **QTSPIM**. 

# **PDS2: Decide upon the size of instruction and data memory**

**Answer: \-** We have kept our **Program Counter (PC) 32 bits wide**. We have kept our **Instruction memory** of 1024 bytes, assuming 256 instructions, each of width 32 bits. The **Data Memory** is also of the same size, i.e. **1024 x 32** bytes

| Size (in bits) | Registers | Usage protocol |
| :---- | :---- | :---- |
| 32 | instruction | Stores the current instruction to be executed |
| 6 | op\_code | Stores opcode of current instruction |
| 5 | rs\_data | Stores address of first source register of current instruction |
| 5 | rt\_data | Stores address of second source register of current instruction |
| 5 | rd\_data | Stores address of destination register of current instruction |
| 5 | shamt | Stores shift amount of current instruction |
| 6 | func | Stores function code of current instruction |
| 26 | address | Stores address of current J type instruction |
| 16 | imm | Stores address of current I type instruction |
| 32 | rs | Stores the data at address of first source register of current instruction |
| 32 | rt | Stores the data at address of second source register of current instruction |
| 32 | rd | Stores the data at address of destination register of current instruction |

# **PDS3: Designing the instruction layout of R, I and J-type instructions and their respective encoding methods.**

**General structure of instruction encoding: \-**

1. **I-Type (immediate)**

<table>
  <thead>
    <!-- Field labels with colspan -->
    <tr>
      <th colspan="6">opcode</th>
      <th colspan="5">rs</th>
      <th colspan="5">rt</th>
      <th colspan="16">imm</th>
    </tr>
    <!-- Bit positions -->
    <tr>
      <th>31</th><th>30</th><th>29</th><th>28</th><th>27</th><th>26</th>
      <th>25</th><th>24</th><th>23</th><th>22</th><th>21</th>
      <th>20</th><th>19</th><th>18</th><th>17</th><th>16</th>
      <th>15</th><th>14</th><th>13</th><th>12</th><th>11</th>
      <th>10</th><th>9</th><th>8</th><th>7</th><th>6</th>
      <th>5</th><th>4</th><th>3</th><th>2</th><th>1</th><th>0</th>
    </tr>
  </thead>
</table>


2. **J-Type (jump)**

<table>
  <thead>
    <!-- Field labels with colspan -->
    <tr>
      <th colspan="6">opcode</th>
      <th colspan="26">address</th>
    </tr>
    <!-- Bit positions -->
    <tr>
      <th>31</th><th>30</th><th>29</th><th>28</th><th>27</th><th>26</th>
      <th>25</th><th>24</th><th>23</th><th>22</th><th>21</th><th>20</th>
      <th>19</th><th>18</th><th>17</th><th>16</th><th>15</th><th>14</th>
      <th>13</th><th>12</th><th>11</th><th>10</th><th>9</th><th>8</th>
      <th>7</th><th>6</th><th>5</th><th>4</th><th>3</th><th>2</th>
      <th>1</th><th>0</th>
    </tr>
  </thead>
</table>


3. **R-Type (register)**
<table>
  <thead>
    <tr>
      <th colspan="6">opcode</th>
      <th colspan="5">rs</th>
      <th colspan="5">rt</th>
      <th colspan="5">rd</th>
      <th colspan="5">shamt</th>
      <th colspan="6">func</th>
    </tr>
    <tr>
      <th>31</th><th>30</th><th>29</th><th>28</th><th>27</th><th>26</th>
      <th>25</th><th>24</th><th>23</th><th>22</th><th>21</th>
      <th>20</th><th>19</th><th>18</th><th>17</th><th>16</th>
      <th>15</th><th>14</th><th>13</th><th>12</th><th>11</th>
      <th>10</th><th>9</th><th>8</th><th>7</th><th>6</th>
      <th>5</th><th>4</th><th>3</th><th>2</th><th>1</th><th>0</th>
    </tr>
  </thead>
</table>


**Instruction encoding: \-**

1. **R-Type**

   For a given instruction, we first check the **opcode**. If that comes out to be **0**, then that instruction is **R type**. Then we check the specific instruction by **func code**.

| Instruction type | Instruction | Instruction encoding |
| :---- | :---- | :---- |
|  R type | add r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 32 |
|  | sub r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 34 |
|  | addu r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 33 |
|  | subu r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 35 |
|  | and r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 36 |
|  | or r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 37 |
|  | xor r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 38 |
|  | not r0, r1 | opcode \= 0, rs, rt, rd, shamt, func \= 39 |
|  | sll r0, r1, 10 | opcode \= 0, rs, rt, rd, shamt, func \= 0 |
|  | sllv r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 4 |
|  | srl r0, r1, 10 | opcode \= 0, rs, rt, rd, shamt, func \= 2 |
|  | srlv r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 6 |
|  | sra r0, r1, 10 | opcode \= 0, rs, rt, rd, shamt, func \= 3 |
|  | jr r0 | opcode \= 0, rs, rt, rd, shamt, func \= 8 |
|  |  madd r0, r1 | opcode \= 0, rs, rt, rd, shamt, func \= 25 |
|  |  maddu r0, r1 | opcode \= 0, rs, rt, rd, shamt, func \= 26 |
|  |  mul r0, r1 | opcode \= 0, rs, rt, rd, shamt, func \= 24 |
|  | slt r0, r1, r2 | opcode \= 0, rs, rt, rd, shamt, func \= 42 |

2. **J-Type**

   For a given instruction, we first check the **opcode**. If that comes out to be **2 or 3,** then that instruction is **J type**.

| Instruction type | Instruction | Instruction encoding |
| ----- | :---- | :---- |
| J type | j 10 | opcode \= 2, address as per instruction |
|  | jal 10 | opcode \= 3, address as per instruction |

3. **I-Type**

| Instruction type | Instruction | Instruction encoding |
| ----- | :---- | :---- |
|  I type | addi r0, r1, 1000 | opcode \= 8, rs, rt, imm |
|  | addiu r0, r1, 1000 | opcode \= 9, rs, rt, imm |
|  | andi r0, r1, 1000 | opcode \= 12, rs, rt, imm |
|  | ori r0, r1, 1000 | opcode \= 13, rs, rt, imm |
|  | xori r0, r1, 1000 | opcode \= 14, rs, rt, imm |
|  | lui r0, 1000 | opcode \= 15, rs, rt, imm |
|  | lw r0, 10(r1) | opcode \= 35, rs, rt, imm |
|  | sw r0, 10(r1) | opcode \= 43, rs, rt, imm |
|  | beq r0, r1, 10 | opcode \= 4, rs, rt, imm |
|  | bne r0, r1, 10 | opcode \= 5, rs, rt, imm |
|  | bgte r0, r1, 10 | opcode \= 60, rs, rt, imm |
|  | ble r0, r1, 10 | opcode \= 49, rs, rt, imm |
|  | slti 1, 2, 100 | opcode \= 10, rs, rt, imm |

   For a given instruction, we first check the **op code**. If that comes out to be anything else except **{0,2,3},** then that instruction is **I type**.

   

   

   

   

   

   

   

   

   

   

   

   

   

   

   

   

   

