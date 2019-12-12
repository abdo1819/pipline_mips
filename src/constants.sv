// To be used in side ALU / aludec

//ar > arithmatic   1:arithmatic shifting
    // unutlized for non shift 

//sh > shift        1:operation is shift

//~b > not b        1:invert b
    //unutlized for shift (must be 0 in aludec for shift)

//se > selector     
    // if shift { right , variable }    ex:01 sllv/slav
    // if arithmatic  00:and, 01:or, 10:add/sub, 11:slt 

// _________________ar__sh__~b__se
`define EXE_AND  5'b0___0___0___00
`define EXE_OR   5'b0___0___0___01
`define EXE_ADD  5'b0___0___0___10
`define EXE_SUB  5'b0___0___1___10
`define EXE_NOR  5'b0___0___1___10
`define EXE_SLT  5'b0___0___1___11
`define EXE_SLA  5'b1___1___0___00
`define EXE_SLL  5'b0___1___0___00
`define EXE_SLLV 5'b0___1___0___01
`define EXE_SRA  5'b1___1___0___10
`define EXE_SRL  5'b0___1___0___10

