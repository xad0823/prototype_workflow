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




module nic400_ib_slave_if0_0_m_ib_axi_to_itb_sse710_boot_reg
(

  awid,
  awaddr,
  awlen,
  awsize,
  awburst,
  awlock,
  awcache,
  awprot,
  awvalid,
  awready,

  bid,
  bresp,
  bvalid,
  bready,

  arid,
  araddr,
  arlen,
  arsize,
  arburst,
  arlock,
  arcache,
  arprot,
  arvalid,
  arready,

  rid,
  rdata,
  rresp,
  rlast,
  rvalid,
  rready,



  awrite,
  aid,
  aaddr,
  alen,
  asize,
  aburst,
  alock,
  acache,
  aprot,
  avalid,
  aready,

  dbnr,
  did,
  ddata,
  dresp,
  dlast,
  dvalid,
  dready,


  aclk,
  aresetn
);




  input  [9:0]          awid;                  
  input  [31:0]         awaddr;                
  input  [7:0]             awlen;                 
  input  [2:0]          awsize;                
  input  [1:0]          awburst;               
  input                    awlock;                
  input  [3:0]          awcache;               
  input  [2:0]          awprot;                
  input                 awvalid;               
  output                awready;               

  output [9:0]          bid;                   
  output [1:0]          bresp;                 
  output                bvalid;                
  input                 bready;                

  input  [9:0]          arid;                  
  input  [31:0]         araddr;                
  input  [7:0]             arlen;                 
  input  [2:0]          arsize;                
  input  [1:0]          arburst;               
  input                    arlock;                
  input  [3:0]          arcache;               
  input  [2:0]          arprot;                
  input                 arvalid;               
  output                arready;               

  output [9:0]          rid;                   
  output [31:0]         rdata;                 
  output [1:0]          rresp;                 
  output                rlast;                 
  output                rvalid;                
  input                 rready;                



  output                awrite;                
  output [9:0]          aid;                   
  output [31:0]         aaddr;                 
  output [7:0]          alen;                  
  output [2:0]          asize;                 
  output [1:0]          aburst;                
  output                   alock;                 
  output [3:0]          acache;                
  output [2:0]          aprot;                 
  output                avalid;                
  input                 aready;                

  input                 dbnr;                  
  input  [9:0]          did;                   
  input  [31:0]         ddata;                 
  input  [1:0]          dresp;                 
  input                 dlast;                 
  input                 dvalid;                
  output                dready;                


  input                 aclk;                  
  input                 aresetn;               



  wire                  awrite_i;              
  wire                  awrite_nxt;            
  reg                   awrite_reg;            
  wire                  avalid_i;              
  reg                   avalid_reg;            
  reg                   aready_reg;            



  always @(posedge aclk or negedge aresetn)
    begin : p_a_seq
      if (!aresetn)
        begin
          awrite_reg <= 1'b0;
          avalid_reg <= 1'b0;
          aready_reg <= 1'b0;
        end
      else
        begin
          awrite_reg <= awrite_nxt;
          avalid_reg <= avalid_i;
          aready_reg <= aready;
        end
    end 

  assign awrite_nxt = (avalid_i && aready) ? awrite_i
                        : ((avalid_i && (~avalid_reg || aready_reg)) ? ~awrite_i
                          : awrite_reg);

  assign awrite_i = awvalid & ~(awrite_reg & arvalid);

  assign awrite = awrite_i;

  assign {aid,
          aaddr,
          alen,
          asize,
          aburst,
          alock,
          acache,
          aprot} = awrite_i ?
         {awid,
          awaddr,
          awlen,
          awsize,
          awburst,
          awlock,
          awcache,
          awprot} :
         {arid,
          araddr,
          arlen,
          arsize,
          arburst,
          arlock,
          arcache,
          arprot};

  assign avalid_i = awvalid | arvalid;

  assign avalid = avalid_i;

  assign awready = aready & awrite_i;
  assign arready = aready & ~awrite_i;



  assign bresp = dresp;

  assign bid = did;
  assign rid = did;

  assign {rdata,
          rresp,
          rlast} =
         {ddata,
          dresp,
          dlast};

  assign bvalid = dvalid & dbnr;

  assign rvalid = dvalid & ~dbnr;

  assign dready = (dbnr & dvalid) ? bready : rready;


endmodule 



