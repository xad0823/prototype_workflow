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


module nic400_switch2_lrg_arb_sse710_main
#(
  parameter WIDTH = 2
)
(
  input  wire              aclk,         
  input  wire              aresetn,      
  input  wire              update_en,   
  input  wire  [WIDTH-1:0] request,     
  output wire  [WIDTH-1:0] grant        
);


  reg [WIDTH-1:0] p     [WIDTH-1:0]; 
  reg [WIDTH-1:0] p_reg [WIDTH-1:0]; 
  reg [WIDTH-1:0] p_en  [WIDTH-1:0]; 

  reg [WIDTH-1:0] grant_i;           


  assign grant = grant_i;


  always @*
  begin : p_comb_grant
    integer requester;

    for ( requester=0; requester<WIDTH; requester=requester+1 )
    begin


      grant_i[requester] = request[requester] & ~|(request & p[requester]);

    end 
  end 


  always @*
  begin : p_comb_p_alias
    integer row; 
    integer column; 

    for ( row=0; row<WIDTH; row=row+1 )
    begin
      for ( column=0; column<WIDTH; column=column+1 )
      begin
        if ( row < column )
        begin

          p[row][column] = p_reg[row][column];

        end 
        else if ( row == column )
        begin

          p[row][column] = 1'b0;

        end 
        else 
        begin

          p[row][column] = ~p_reg[column][row];

        end 
      end 
    end 
  end 




  always @*
  begin : p_comb_priorities
    integer row; 
    integer column; 

    for ( row=0; row<WIDTH; row=row+1 )
    begin
      for ( column=row+1; column<WIDTH; column=column+1 ) 
      begin                                   


        p_en[row][column]  = update_en & (grant_i[row] | grant_i[column]);

      end 
    end 
  end 

  always @(posedge aclk or negedge aresetn)
  begin : p_seq_priorities
    integer row;
    integer column;

    if (!aresetn)
    begin
      for ( row=0; row<WIDTH; row=row+1 )
      begin
        for ( column=row+1; column<WIDTH; column=column+1 ) 
        begin                                   

          p_reg[row][column] <= 1'b0;

        end
      end
    end else begin
      for ( row=0; row<WIDTH; row=row+1 )
      begin
        for ( column=row+1; column<WIDTH; column=column+1 ) 
        begin                                   

          if (p_en[row][column])
            p_reg[row][column] <= grant_i[row];

        end
      end
    end
  end 


endmodule

