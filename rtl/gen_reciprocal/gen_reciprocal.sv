`include "../graphite.svh"

module gen_reciprocal(
);

    localparam NUMERATOR = 32'h100;
    localparam END_INTERPOLATION_REGION = 32768;     // values beyond this will return 0
    localparam NB_SUBDIVISIONS = 8192;

    localparam SUBDIVISION_SIZE = END_INTERPOLATION_REGION / NB_SUBDIVISIONS;
    localparam NB_BITS_PER_SUBDIVISION = $clog2(SUBDIVISION_SIZE);

    logic [31:0] m_lut[NB_SUBDIVISIONS];
    logic [31:0] b_lut[NB_SUBDIVISIONS];

    logic [31:0] m;

    initial begin
        m = $signed(rdiv(NUMERATOR << 16, 32'((1) * SUBDIVISION_SIZE) << 16) - (NUMERATOR << 16)) >>> NB_BITS_PER_SUBDIVISION;
        m_lut[0] = m[31:0];
        b_lut[0] = NUMERATOR << 16;

        for (int i = 1; i < NB_SUBDIVISIONS; i++) begin
            m = $signed(rdiv(NUMERATOR << 16, 32'((i + 1) * SUBDIVISION_SIZE) << 16) - rdiv(NUMERATOR << 16, 32'(i * SUBDIVISION_SIZE) << 16)) >>> NB_BITS_PER_SUBDIVISION;
            m_lut[i] = m[31:0];
            b_lut[i] = rdiv(NUMERATOR << 16, 32'(i * SUBDIVISION_SIZE) << 16);
        end
    end

    integer f_m, f_b, i;
    initial begin
        f_m = $fopen("../reciprocal_m_lut.hex","w");
        f_b = $fopen("../reciprocal_b_lut.hex","w");
        for (i = 0; i < NB_SUBDIVISIONS; i++) begin
            $fwrite(f_m,"%x\n",m_lut[i]);
            $fwrite(f_b,"%x\n",b_lut[i]);
        end
        $fclose(f_b);
        $fclose(f_m);
    end

endmodule