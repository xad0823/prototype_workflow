//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------





module nic400_ib_apb_group0_ib_itb_to_axi_sse710_integration_example_f0_host_exp
(

  awrite,
  aaddr,
  alen,
  asize,
  aburst,
  alock,
  acache,
  aprot,
  aregion,
  avalid,
  aready,

  dbnr,
  ddata,
  dresp,
  dlast,
  dvalid,
  dready,



  awaddr,
  awlen,
  awsize,
  awburst,
  awlock,
  awcache,
  awprot,
  awregion,
  awvalid,
  awready,

  bresp,
  bvalid,
  bready,

  araddr,
  arlen,
  arsize,
  arburst,
  arlock,
  arcache,
  arprot,
  arregion,
  arvalid,
  arready,

  rdata,
  rresp,
  rlast,
  rvalid,
  rready,


  aclk,
  aresetn
);




  input                 awrite;                
  input  [31:0]         aaddr;                 
  input  [7:0]             alen;                  
  input  [2:0]          asize;                 
  input  [1:0]          aburst;                
  input                         alock;                 
  input  [3:0]          acache;                
  input  [2:0]          aprot;                 
  input  [3:0]          aregion;               
  input                 avalid;                
  output                aready;                

  output                dbnr;                  
  output [31:0]         ddata;                 
  output [1:0]          dresp;                 
  output                dlast;                 
  output                dvalid;                
  input                 dready;                



  output [31:0]         awaddr;                
  output  [7:0]             awlen;                 
  output [2:0]          awsize;                
  output [1:0]          awburst;               
  output                         awlock;                
  output [3:0]          awcache;               
  output [2:0]          awprot;                
  output [3:0]          awregion;              
  output                awvalid;               
  input                 awready;               

  input  [1:0]          bresp;                 
  input                 bvalid;                
  output                bready;                

  output [31:0]         araddr;                
  output  [7:0]             arlen;                 
  output [2:0]          arsize;                
  output [1:0]          arburst;               
  output                         arlock;                
  output [3:0]          arcache;               
  output [2:0]          arprot;                
  output [3:0]          arregion;              
  output                arvalid;               
  input                 arready;               

  input  [31:0]         rdata;                 
  input  [1:0]          rresp;                 
  input                 rlast;                 
  input                 rvalid;                
  output                rready;                


  input                 aclk;                  
  input                 aresetn;               



  wire                  dbnr_i;                
  wire                  dbnr_nxt;              
  reg                   dbnr_reg;              
  wire                  dvalid_i;              
  reg                   dvalid_reg;            
  reg                   dready_reg;            




  assign {awaddr,
          awlen,
          awsize,
          awburst,
          awlock,
          awcache,
          awprot} =
         {aaddr,
          alen,
          asize,
          aburst,
          alock,
          acache,
          aprot};

  assign awregion = aregion;
  assign arregion = aregion;

  assign {araddr,
          arlen,
          arsize,
          arburst,
          arlock,
          arcache,
          arprot} =
         {aaddr,
          alen,
          asize,
          aburst,
          alock,
          acache,
          aprot};

  assign awvalid = avalid & awrite;

  assign arvalid = avalid & ~awrite;

  assign aready = (awrite & avalid) ? awready : arready;


  always @(posedge aclk or negedge aresetn)
    begin : p_d_seq
      if (!aresetn)
        begin
          dbnr_reg   <= 1'b0;
          dvalid_reg <= 1'b0;
          dready_reg <= 1'b0;
        end
      else
        begin
          dbnr_reg   <= dbnr_nxt;
          dvalid_reg <= dvalid_i;
          dready_reg <= dready;
        end
    end 

  assign dbnr_nxt = (dvalid_i && dready) ? dbnr_i
                      : ((dvalid_i && (~dvalid_reg || dready_reg)) ? ~dbnr_i
                        : dbnr_reg);

  assign dbnr_i = bvalid & ~(dbnr_reg & rvalid);

  assign dbnr = dbnr_i;

  assign {dresp} = dbnr_i ?
         {bresp} :
         {rresp};

  assign ddata = rdata;

  assign dlast = rlast;

  assign dvalid_i = bvalid | rvalid;

  assign dvalid = dvalid_i;

  assign bready = dready & dbnr_i;
  assign rready = dready & ~dbnr_i;



endmodule 



