//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_apbic
//
//----------------------------------------------------------------------------


module css600_apbicdecoder_stage1 #(parameter
  `include "css600_apbic_params.v"
)
(
  input  wire                            cycle_start,
  input  wire [APB_SLAVE_ADDR_WIDTH-1:0] paddr_s_arb,
  output wire [NUM_APB_MASTERS-1:0]      psel_m,
  output wire                            psel_default
);

  wire [63:0] psel_m_next;

  assign psel_m = psel_m_next[NUM_APB_MASTERS-1:0];

  assign psel_default = ~|(psel_m_next[NUM_APB_MASTERS-1:0]);


  generate

    if (NUM_APB_MASTERS>0)
      if (APB_SLAVE_ADDR_WIDTH <= M0_ADDR_WIDTH) begin: gen_default_psel_m0
        assign psel_m_next[0] = cycle_start;
      end
      else begin: gen_psel_m0
        assign psel_m_next[0] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M0_ADDR_WIDTH]
          == M0_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M0_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>1)
      if (APB_SLAVE_ADDR_WIDTH <= M1_ADDR_WIDTH) begin: gen_default_psel_m1
        assign psel_m_next[1] = cycle_start;
      end
      else begin: gen_psel_m1
        assign psel_m_next[1] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M1_ADDR_WIDTH]
          == M1_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M1_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>2)
      if (APB_SLAVE_ADDR_WIDTH <= M2_ADDR_WIDTH) begin: gen_default_psel_m2
        assign psel_m_next[2] = cycle_start;
      end
      else begin: gen_psel_m2
        assign psel_m_next[2] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M2_ADDR_WIDTH]
          == M2_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M2_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>3)
      if (APB_SLAVE_ADDR_WIDTH <= M3_ADDR_WIDTH) begin: gen_default_psel_m3
        assign psel_m_next[3] = cycle_start;
      end
      else begin: gen_psel_m3
        assign psel_m_next[3] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M3_ADDR_WIDTH]
          == M3_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M3_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>4)
      if (APB_SLAVE_ADDR_WIDTH <= M4_ADDR_WIDTH) begin: gen_default_psel_m4
        assign psel_m_next[4] = cycle_start;
      end
      else begin: gen_psel_m4
        assign psel_m_next[4] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M4_ADDR_WIDTH]
          == M4_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M4_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>5)
      if (APB_SLAVE_ADDR_WIDTH <= M5_ADDR_WIDTH) begin: gen_default_psel_m5
        assign psel_m_next[5] = cycle_start;
      end
      else begin: gen_psel_m5
        assign psel_m_next[5] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M5_ADDR_WIDTH]
          == M5_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M5_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>6)
      if (APB_SLAVE_ADDR_WIDTH <= M6_ADDR_WIDTH) begin: gen_default_psel_m6
        assign psel_m_next[6] = cycle_start;
      end
      else begin: gen_psel_m6
        assign psel_m_next[6] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M6_ADDR_WIDTH]
          == M6_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M6_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>7)
      if (APB_SLAVE_ADDR_WIDTH <= M7_ADDR_WIDTH) begin: gen_default_psel_m7
        assign psel_m_next[7] = cycle_start;
      end
      else begin: gen_psel_m7
        assign psel_m_next[7] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M7_ADDR_WIDTH]
          == M7_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M7_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>8)
      if (APB_SLAVE_ADDR_WIDTH <= M8_ADDR_WIDTH) begin: gen_default_psel_m8
        assign psel_m_next[8] = cycle_start;
      end
      else begin: gen_psel_m8
        assign psel_m_next[8] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M8_ADDR_WIDTH]
          == M8_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M8_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>9)
      if (APB_SLAVE_ADDR_WIDTH <= M9_ADDR_WIDTH) begin: gen_default_psel_m9
        assign psel_m_next[9] = cycle_start;
      end
      else begin: gen_psel_m9
        assign psel_m_next[9] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M9_ADDR_WIDTH]
          == M9_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M9_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>10)
      if (APB_SLAVE_ADDR_WIDTH <= M10_ADDR_WIDTH) begin: gen_default_psel_m10
        assign psel_m_next[10] = cycle_start;
      end
      else begin: gen_psel_m10
        assign psel_m_next[10] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M10_ADDR_WIDTH]
          == M10_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M10_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>11)
      if (APB_SLAVE_ADDR_WIDTH <= M11_ADDR_WIDTH) begin: gen_default_psel_m11
        assign psel_m_next[11] = cycle_start;
      end
      else begin: gen_psel_m11
        assign psel_m_next[11] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M11_ADDR_WIDTH]
          == M11_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M11_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>12)
      if (APB_SLAVE_ADDR_WIDTH <= M12_ADDR_WIDTH) begin: gen_default_psel_m12
        assign psel_m_next[12] = cycle_start;
      end
      else begin: gen_psel_m12
        assign psel_m_next[12] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M12_ADDR_WIDTH]
          == M12_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M12_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>13)
      if (APB_SLAVE_ADDR_WIDTH <= M13_ADDR_WIDTH) begin: gen_default_psel_m13
        assign psel_m_next[13] = cycle_start;
      end
      else begin: gen_psel_m13
        assign psel_m_next[13] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M13_ADDR_WIDTH]
          == M13_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M13_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>14)
      if (APB_SLAVE_ADDR_WIDTH <= M14_ADDR_WIDTH) begin: gen_default_psel_m14
        assign psel_m_next[14] = cycle_start;
      end
      else begin: gen_psel_m14
        assign psel_m_next[14] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M14_ADDR_WIDTH]
          == M14_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M14_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>15)
      if (APB_SLAVE_ADDR_WIDTH <= M15_ADDR_WIDTH) begin: gen_default_psel_m15
        assign psel_m_next[15] = cycle_start;
      end
      else begin: gen_psel_m15
        assign psel_m_next[15] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M15_ADDR_WIDTH]
          == M15_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M15_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>16)
      if (APB_SLAVE_ADDR_WIDTH <= M16_ADDR_WIDTH) begin: gen_default_psel_m16
        assign psel_m_next[16] = cycle_start;
      end
      else begin: gen_psel_m16
        assign psel_m_next[16] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M16_ADDR_WIDTH]
          == M16_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M16_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>17)
      if (APB_SLAVE_ADDR_WIDTH <= M17_ADDR_WIDTH) begin: gen_default_psel_m17
        assign psel_m_next[17] = cycle_start;
      end
      else begin: gen_psel_m17
        assign psel_m_next[17] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M17_ADDR_WIDTH]
          == M17_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M17_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>18)
      if (APB_SLAVE_ADDR_WIDTH <= M18_ADDR_WIDTH) begin: gen_default_psel_m18
        assign psel_m_next[18] = cycle_start;
      end
      else begin: gen_psel_m18
        assign psel_m_next[18] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M18_ADDR_WIDTH]
          == M18_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M18_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>19)
      if (APB_SLAVE_ADDR_WIDTH <= M19_ADDR_WIDTH) begin: gen_default_psel_m19
        assign psel_m_next[19] = cycle_start;
      end
      else begin: gen_psel_m19
        assign psel_m_next[19] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M19_ADDR_WIDTH]
          == M19_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M19_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>20)
      if (APB_SLAVE_ADDR_WIDTH <= M20_ADDR_WIDTH) begin: gen_default_psel_m20
        assign psel_m_next[20] = cycle_start;
      end
      else begin: gen_psel_m20
        assign psel_m_next[20] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M20_ADDR_WIDTH]
          == M20_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M20_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>21)
      if (APB_SLAVE_ADDR_WIDTH <= M21_ADDR_WIDTH) begin: gen_default_psel_m21
        assign psel_m_next[21] = cycle_start;
      end
      else begin: gen_psel_m21
        assign psel_m_next[21] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M21_ADDR_WIDTH]
          == M21_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M21_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>22)
      if (APB_SLAVE_ADDR_WIDTH <= M22_ADDR_WIDTH) begin: gen_default_psel_m22
        assign psel_m_next[22] = cycle_start;
      end
      else begin: gen_psel_m22
        assign psel_m_next[22] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M22_ADDR_WIDTH]
          == M22_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M22_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>23)
      if (APB_SLAVE_ADDR_WIDTH <= M23_ADDR_WIDTH) begin: gen_default_psel_m23
        assign psel_m_next[23] = cycle_start;
      end
      else begin: gen_psel_m23
        assign psel_m_next[23] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M23_ADDR_WIDTH]
          == M23_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M23_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>24)
      if (APB_SLAVE_ADDR_WIDTH <= M24_ADDR_WIDTH) begin: gen_default_psel_m24
        assign psel_m_next[24] = cycle_start;
      end
      else begin: gen_psel_m24
        assign psel_m_next[24] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M24_ADDR_WIDTH]
          == M24_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M24_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>25)
      if (APB_SLAVE_ADDR_WIDTH <= M25_ADDR_WIDTH) begin: gen_default_psel_m25
        assign psel_m_next[25] = cycle_start;
      end
      else begin: gen_psel_m25
        assign psel_m_next[25] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M25_ADDR_WIDTH]
          == M25_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M25_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>26)
      if (APB_SLAVE_ADDR_WIDTH <= M26_ADDR_WIDTH) begin: gen_default_psel_m26
        assign psel_m_next[26] = cycle_start;
      end
      else begin: gen_psel_m26
        assign psel_m_next[26] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M26_ADDR_WIDTH]
          == M26_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M26_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>27)
      if (APB_SLAVE_ADDR_WIDTH <= M27_ADDR_WIDTH) begin: gen_default_psel_m27
        assign psel_m_next[27] = cycle_start;
      end
      else begin: gen_psel_m27
        assign psel_m_next[27] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M27_ADDR_WIDTH]
          == M27_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M27_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>28)
      if (APB_SLAVE_ADDR_WIDTH <= M28_ADDR_WIDTH) begin: gen_default_psel_m28
        assign psel_m_next[28] = cycle_start;
      end
      else begin: gen_psel_m28
        assign psel_m_next[28] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M28_ADDR_WIDTH]
          == M28_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M28_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>29)
      if (APB_SLAVE_ADDR_WIDTH <= M29_ADDR_WIDTH) begin: gen_default_psel_m29
        assign psel_m_next[29] = cycle_start;
      end
      else begin: gen_psel_m29
        assign psel_m_next[29] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M29_ADDR_WIDTH]
          == M29_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M29_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>30)
      if (APB_SLAVE_ADDR_WIDTH <= M30_ADDR_WIDTH) begin: gen_default_psel_m30
        assign psel_m_next[30] = cycle_start;
      end
      else begin: gen_psel_m30
        assign psel_m_next[30] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M30_ADDR_WIDTH]
          == M30_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M30_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>31)
      if (APB_SLAVE_ADDR_WIDTH <= M31_ADDR_WIDTH) begin: gen_default_psel_m31
        assign psel_m_next[31] = cycle_start;
      end
      else begin: gen_psel_m31
        assign psel_m_next[31] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M31_ADDR_WIDTH]
          == M31_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M31_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>32)
      if (APB_SLAVE_ADDR_WIDTH <= M32_ADDR_WIDTH) begin: gen_default_psel_m32
        assign psel_m_next[32] = cycle_start;
      end
      else begin: gen_psel_m32
        assign psel_m_next[32] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M32_ADDR_WIDTH]
          == M32_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M32_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>33)
      if (APB_SLAVE_ADDR_WIDTH <= M33_ADDR_WIDTH) begin: gen_default_psel_m33
        assign psel_m_next[33] = cycle_start;
      end
      else begin: gen_psel_m33
        assign psel_m_next[33] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M33_ADDR_WIDTH]
          == M33_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M33_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>34)
      if (APB_SLAVE_ADDR_WIDTH <= M34_ADDR_WIDTH) begin: gen_default_psel_m34
        assign psel_m_next[34] = cycle_start;
      end
      else begin: gen_psel_m34
        assign psel_m_next[34] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M34_ADDR_WIDTH]
          == M34_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M34_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>35)
      if (APB_SLAVE_ADDR_WIDTH <= M35_ADDR_WIDTH) begin: gen_default_psel_m35
        assign psel_m_next[35] = cycle_start;
      end
      else begin: gen_psel_m35
        assign psel_m_next[35] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M35_ADDR_WIDTH]
          == M35_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M35_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>36)
      if (APB_SLAVE_ADDR_WIDTH <= M36_ADDR_WIDTH) begin: gen_default_psel_m36
        assign psel_m_next[36] = cycle_start;
      end
      else begin: gen_psel_m36
        assign psel_m_next[36] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M36_ADDR_WIDTH]
          == M36_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M36_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>37)
      if (APB_SLAVE_ADDR_WIDTH <= M37_ADDR_WIDTH) begin: gen_default_psel_m37
        assign psel_m_next[37] = cycle_start;
      end
      else begin: gen_psel_m37
        assign psel_m_next[37] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M37_ADDR_WIDTH]
          == M37_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M37_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>38)
      if (APB_SLAVE_ADDR_WIDTH <= M38_ADDR_WIDTH) begin: gen_default_psel_m38
        assign psel_m_next[38] = cycle_start;
      end
      else begin: gen_psel_m38
        assign psel_m_next[38] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M38_ADDR_WIDTH]
          == M38_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M38_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>39)
      if (APB_SLAVE_ADDR_WIDTH <= M39_ADDR_WIDTH) begin: gen_default_psel_m39
        assign psel_m_next[39] = cycle_start;
      end
      else begin: gen_psel_m39
        assign psel_m_next[39] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M39_ADDR_WIDTH]
          == M39_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M39_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>40)
      if (APB_SLAVE_ADDR_WIDTH <= M40_ADDR_WIDTH) begin: gen_default_psel_m40
        assign psel_m_next[40] = cycle_start;
      end
      else begin: gen_psel_m40
        assign psel_m_next[40] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M40_ADDR_WIDTH]
          == M40_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M40_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>41)
      if (APB_SLAVE_ADDR_WIDTH <= M41_ADDR_WIDTH) begin: gen_default_psel_m41
        assign psel_m_next[41] = cycle_start;
      end
      else begin: gen_psel_m41
        assign psel_m_next[41] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M41_ADDR_WIDTH]
          == M41_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M41_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>42)
      if (APB_SLAVE_ADDR_WIDTH <= M42_ADDR_WIDTH) begin: gen_default_psel_m42
        assign psel_m_next[42] = cycle_start;
      end
      else begin: gen_psel_m42
        assign psel_m_next[42] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M42_ADDR_WIDTH]
          == M42_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M42_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>43)
      if (APB_SLAVE_ADDR_WIDTH <= M43_ADDR_WIDTH) begin: gen_default_psel_m43
        assign psel_m_next[43] = cycle_start;
      end
      else begin: gen_psel_m43
        assign psel_m_next[43] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M43_ADDR_WIDTH]
          == M43_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M43_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>44)
      if (APB_SLAVE_ADDR_WIDTH <= M44_ADDR_WIDTH) begin: gen_default_psel_m44
        assign psel_m_next[44] = cycle_start;
      end
      else begin: gen_psel_m44
        assign psel_m_next[44] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M44_ADDR_WIDTH]
          == M44_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M44_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>45)
      if (APB_SLAVE_ADDR_WIDTH <= M45_ADDR_WIDTH) begin: gen_default_psel_m45
        assign psel_m_next[45] = cycle_start;
      end
      else begin: gen_psel_m45
        assign psel_m_next[45] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M45_ADDR_WIDTH]
          == M45_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M45_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>46)
      if (APB_SLAVE_ADDR_WIDTH <= M46_ADDR_WIDTH) begin: gen_default_psel_m46
        assign psel_m_next[46] = cycle_start;
      end
      else begin: gen_psel_m46
        assign psel_m_next[46] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M46_ADDR_WIDTH]
          == M46_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M46_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>47)
      if (APB_SLAVE_ADDR_WIDTH <= M47_ADDR_WIDTH) begin: gen_default_psel_m47
        assign psel_m_next[47] = cycle_start;
      end
      else begin: gen_psel_m47
        assign psel_m_next[47] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M47_ADDR_WIDTH]
          == M47_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M47_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>48)
      if (APB_SLAVE_ADDR_WIDTH <= M48_ADDR_WIDTH) begin: gen_default_psel_m48
        assign psel_m_next[48] = cycle_start;
      end
      else begin: gen_psel_m48
        assign psel_m_next[48] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M48_ADDR_WIDTH]
          == M48_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M48_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>49)
      if (APB_SLAVE_ADDR_WIDTH <= M49_ADDR_WIDTH) begin: gen_default_psel_m49
        assign psel_m_next[49] = cycle_start;
      end
      else begin: gen_psel_m49
        assign psel_m_next[49] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M49_ADDR_WIDTH]
          == M49_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M49_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>50)
      if (APB_SLAVE_ADDR_WIDTH <= M50_ADDR_WIDTH) begin: gen_default_psel_m50
        assign psel_m_next[50] = cycle_start;
      end
      else begin: gen_psel_m50
        assign psel_m_next[50] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M50_ADDR_WIDTH]
          == M50_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M50_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>51)
      if (APB_SLAVE_ADDR_WIDTH <= M51_ADDR_WIDTH) begin: gen_default_psel_m51
        assign psel_m_next[51] = cycle_start;
      end
      else begin: gen_psel_m51
        assign psel_m_next[51] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M51_ADDR_WIDTH]
          == M51_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M51_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>52)
      if (APB_SLAVE_ADDR_WIDTH <= M52_ADDR_WIDTH) begin: gen_default_psel_m52
        assign psel_m_next[52] = cycle_start;
      end
      else begin: gen_psel_m52
        assign psel_m_next[52] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M52_ADDR_WIDTH]
          == M52_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M52_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>53)
      if (APB_SLAVE_ADDR_WIDTH <= M53_ADDR_WIDTH) begin: gen_default_psel_m53
        assign psel_m_next[53] = cycle_start;
      end
      else begin: gen_psel_m53
        assign psel_m_next[53] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M53_ADDR_WIDTH]
          == M53_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M53_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>54)
      if (APB_SLAVE_ADDR_WIDTH <= M54_ADDR_WIDTH) begin: gen_default_psel_m54
        assign psel_m_next[54] = cycle_start;
      end
      else begin: gen_psel_m54
        assign psel_m_next[54] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M54_ADDR_WIDTH]
          == M54_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M54_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>55)
      if (APB_SLAVE_ADDR_WIDTH <= M55_ADDR_WIDTH) begin: gen_default_psel_m55
        assign psel_m_next[55] = cycle_start;
      end
      else begin: gen_psel_m55
        assign psel_m_next[55] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M55_ADDR_WIDTH]
          == M55_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M55_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>56)
      if (APB_SLAVE_ADDR_WIDTH <= M56_ADDR_WIDTH) begin: gen_default_psel_m56
        assign psel_m_next[56] = cycle_start;
      end
      else begin: gen_psel_m56
        assign psel_m_next[56] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M56_ADDR_WIDTH]
          == M56_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M56_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>57)
      if (APB_SLAVE_ADDR_WIDTH <= M57_ADDR_WIDTH) begin: gen_default_psel_m57
        assign psel_m_next[57] = cycle_start;
      end
      else begin: gen_psel_m57
        assign psel_m_next[57] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M57_ADDR_WIDTH]
          == M57_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M57_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>58)
      if (APB_SLAVE_ADDR_WIDTH <= M58_ADDR_WIDTH) begin: gen_default_psel_m58
        assign psel_m_next[58] = cycle_start;
      end
      else begin: gen_psel_m58
        assign psel_m_next[58] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M58_ADDR_WIDTH]
          == M58_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M58_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>59)
      if (APB_SLAVE_ADDR_WIDTH <= M59_ADDR_WIDTH) begin: gen_default_psel_m59
        assign psel_m_next[59] = cycle_start;
      end
      else begin: gen_psel_m59
        assign psel_m_next[59] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M59_ADDR_WIDTH]
          == M59_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M59_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>60)
      if (APB_SLAVE_ADDR_WIDTH <= M60_ADDR_WIDTH) begin: gen_default_psel_m60
        assign psel_m_next[60] = cycle_start;
      end
      else begin: gen_psel_m60
        assign psel_m_next[60] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M60_ADDR_WIDTH]
          == M60_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M60_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>61)
      if (APB_SLAVE_ADDR_WIDTH <= M61_ADDR_WIDTH) begin: gen_default_psel_m61
        assign psel_m_next[61] = cycle_start;
      end
      else begin: gen_psel_m61
        assign psel_m_next[61] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M61_ADDR_WIDTH]
          == M61_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M61_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>62)
      if (APB_SLAVE_ADDR_WIDTH <= M62_ADDR_WIDTH) begin: gen_default_psel_m62
        assign psel_m_next[62] = cycle_start;
      end
      else begin: gen_psel_m62
        assign psel_m_next[62] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M62_ADDR_WIDTH]
          == M62_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M62_ADDR_WIDTH]);
      end

    if (NUM_APB_MASTERS>63)
      if (APB_SLAVE_ADDR_WIDTH <= M63_ADDR_WIDTH) begin: gen_default_psel_m63
        assign psel_m_next[63] = cycle_start;
      end
      else begin: gen_psel_m63
        assign psel_m_next[63] = cycle_start &
          (paddr_s_arb [APB_SLAVE_ADDR_WIDTH-1:M63_ADDR_WIDTH]
          == M63_BASE_ADDR[APB_SLAVE_ADDR_WIDTH-1:M63_ADDR_WIDTH]);
      end

  endgenerate

endmodule
