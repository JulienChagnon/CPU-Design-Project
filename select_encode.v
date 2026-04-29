module select_encode(
    // full 32-bit instruction currently stored in ir
    input  wire [31:0] IR,

    // these pick which ir field Ra, Rb, or Rc should be used as the register index
    input  wire Gra,
    input  wire Grb,
    input  wire Grc,

    // control bits that enable decoded write/read register lines
    input  wire Rin,
    input  wire Rout,

    // base address mode; this also enables the decoded rout path
    input  wire BAout,

    // controls whether the immediate constant path is active in sign_extend
    input  wire Cout,

    // one-hot write enables for r0..r15
    output wire [15:0] Rin_decoded,
    // one-hot read enables for r0..r15
    output wire [15:0] Rout_decoded,

    // 32-bit immediate constant output built from ir[18:0]
    output wire [31:0] C_sign_extended
);

    // extract the 3 register fields from fixed ir bit ranges
    wire [3:0] Ra = IR[26:23];
    wire [3:0] Rb = IR[22:19];
    wire [3:0] Rc = IR[18:15];

    // AND each register with its control field, OR all fields to feed into 4 to 16 decoder
    wire [3:0] reg_sel = ({4{Gra}} & Ra) | ({4{Grb}} & Rb) | ({4{Grc}} & Rc);

    // convert selected 4-bit index into one-hot 16-bit decode
    wire [15:0] dec = (16'b1 << reg_sel);

    // decoded rout path should turn on if either rout or baout is asserted
    wire rout_enable = Rout | BAout;

    // gate decoded outputs with the control enables
    assign Rin_decoded  = Rin         ? dec : 16'b0;
    assign Rout_decoded = rout_enable ? dec : 16'b0;

    // use the existing sign_extend module instead of duplicating that logic here
    sign_extend sign_extend_u (
        .IR(IR),
        .Cout(Cout),
        .C_sign_extended(C_sign_extended)
    );

endmodule
