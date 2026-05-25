integer cpiid0;
always @(posedge tarmac_enable)
begin
  cpiid0 = ca53_declare("CiJ1bml2ZW50LmNvcnRleGE1My5UcmFjZUluc3RydWN0aW9uEhYKDmluc3RyX2NvdW50X3dyIgQIQBAAEhkKEXZhbGlkX2luc3Ryc193cl8xIgQIARABEhUKDWlzYV9pbnN0cjBfd3IiBAgCEAISFQoNaXNhX2luc3RyMV93ciIECAIQAxIWCg5zaXplX2luc3RyMF93ciIECAEQBBIWCg5zaXplX2luc3RyMV93ciIECAEQBRISCgpvcGNvZGUwX3dyIgQIIBAGEhIKCm9wY29kZTFfd3IiBAggEAcSFgoOaW5zdHIwX2FkZHJfd3IiBAhAEAgSFgoOaW5zdHIxX2FkZHJfd3IiBAhAEAkSGQoRY2NfcGFzc19pbnN0cjBfd3IiBAgBEAoSGQoRY2NfcGFzc19pbnN0cjFfd3IiBAgBEAsSDgoGbnNfc2NyIgQIARAMEhAKCGNwc3JfcmV0IgQIIBANEg8KB2luX2hhbHQiBAgBEA4SIwoVcmZfd3JfY3RsX2Z3MF9uZW9uX3dyEgQIARAPIgQIFRAQEiMKFXJmX3dyX2N0bF9mdzFfbmVvbl93chIECAEQESIECBUQEhIZChFzbG90MF9icl9mbHVzaF93ciIECAEQExIaChJzaWRlYmFuZF91bmRlZjBfd3IiBAgBEBQSGgoSc2lkZWJhbmRfdW5kZWYxX3dyIgQIARAVEhsKE2V4cHRfaW5zdHJfZmF1bHRfd3IiBAgBEBYSHwoXc2lkZWJhbmRfaHdfYmtwdF92YzBfd3IiBAgBEBcSFwoPdGFrZV9pbF90cmFwX3dyIgQIARAYEhMKC3Nsb3QxX2ZwX3dyIgQIARAZEhgKEGV4cHRfcGNfYWxpZ25fd3IiBAgBEBoSGAoQYWVzX29wX21lcmdlZF93ciIECAEQGxoCWAE=");
end


always @(posedge clk)
  if (instr_sample_wr & tarmac_enable)
  begin
    ca53_probe(instr_count_wr[63:0]);
    ca53_probe(valid_instrs_wr[1]);
    ca53_probe(isa_instr0_wr[1:0]);
    ca53_probe(isa_instr1_wr[1:0]);
    ca53_probe(size_instr0_wr);
    ca53_probe(size_instr1_wr);
    ca53_probe(opcode0_wr[31:0]);
    ca53_probe(opcode1_wr[31:0]);
    ca53_probe(instr0_addr_wr[63:0]);
    ca53_probe(instr1_addr_wr[63:0]);
    ca53_probe(cc_pass_instr0_wr);
    ca53_probe(cc_pass_instr1_wr);
    ca53_probe(ns_scr);
    ca53_probe(cpsr_ret[31:0]);
    ca53_probe(in_halt);
    ca53_probe(fdivs_valid_f3);
    ca53_probe(rf_wr_ctl_fw0_neon_wr[20:0]);
    ca53_probe(fdivs_valid_f3);
    ca53_probe(rf_wr_ctl_fw1_neon_wr[20:0]);
    ca53_probe(slot0_br_flush_wr);
    ca53_probe(sideband_undef0_wr);
    ca53_probe(sideband_undef1_wr);
    ca53_probe(expt_instr_fault_wr);
    ca53_probe(sideband_hw_bkpt_vc0_wr);
    ca53_probe(take_il_trap_wr);
    ca53_probe(slot1_fp_wr);
    ca53_probe(expt_pc_align_wr);
    ca53_probe(aes_op_merged_wr);
    ca53_activate(cpiid0, longint'($time));
  end

integer cpiid1;
always @(posedge tarmac_enable)
begin
  cpiid1 = ca53_declare("Cid1bml2ZW50LmNvcnRleGE1My5UcmFjZVNsb3QxSW5zdHJ1Y3Rpb24SFgoOc2l6ZV9pbnN0cjFfd3IiBAgBEAASEgoKb3Bjb2RlMV93ciIECCAQARIWCg5pbnN0cjFfYWRkcl93ciIECEAQAhIZChFjY19wYXNzX2luc3RyMV93ciIECAEQAxIaChJzaWRlYmFuZF91bmRlZjFfd3IiBAgBEAQSEwoLc2xvdDFfZnBfd3IiBAgBEAUaAlgC");
end


always @(posedge clk)
  if (slot1_instr_sample_wr & tarmac_enable)
  begin
    ca53_probe(size_instr1_wr);
    ca53_probe(opcode1_wr[31:0]);
    ca53_probe(instr1_addr_wr[63:0]);
    ca53_probe(cc_pass_instr1_wr);
    ca53_probe(sideband_undef1_wr);
    ca53_probe(slot1_fp_wr);
    ca53_activate(cpiid1, longint'($time));
  end

integer cpiid2;
always @(posedge tarmac_enable)
begin
  cpiid2 = ca53_declare("CiB1bml2ZW50LmNvcnRleGE1My5UcmFjZU1lbUFjY2VzcxIWCg5pbnN0cl9jb3VudF93ciIECEAQABIZChF2YWxpZF9pbnN0cnNfd3JfMSIECAEQARITCgtzbG90MV9sc193ciIECAEQAhIQCghtZW1fYWRkciIECEAQAxIWCg5zaXplX2luc3RyMF93ciIECAEQBBITCgtsc19zdG9yZV93ciIECAEQBRIZChFkcHVfc3RfZGF0YV93cl9sbyIECEAQBhIZChFkcHVfc3RfZGF0YV93cl9oaSIECEAQBxIXCg9kY3VfbGRfZGF0YV9kYzMiBAhAEAgSEgoKc3Ryb2JlX2RjMyIECBAQCRIXCg9sb2FkX3N0cm9iZV9kYzMiBAgIEAoSEgoKZGN1X3BhX2RjMyIECCgQCxISCgpuc19kc2NfZGMzIgQIARAMEhEKCWF0dHJzX2RjMyIECAgQDRIXCg9kY3Vfd3B0X2hpdF9kYzMiBAgBEA4SGgoSZGN1X3N0cmV4X29rYXlfZGMzIgQIARAPEhcKD2RjdV9wX2Fib3J0X2RjMyIECAEQEBoCWAM=");
end


always @(posedge clk)
  if (mem_sample & tarmac_enable)
  begin
    ca53_probe(instr_count_wr[63:0]);
    ca53_probe(valid_instrs_wr[1]);
    ca53_probe(slot1_ls_wr);
    ca53_probe(mem_addr[63:0]);
    ca53_probe(size_instr0_wr);
    ca53_probe(ls_store_wr);
    ca53_probe(dpu_st_data_wr[63:0]);
    ca53_probe(dpu_st_data_wr[127:64]);
    ca53_probe(dcu_ld_data_dc3[63:0]);
    ca53_probe(strobe_dc3[15:0]);
    ca53_probe(load_strobe_dc3[7:0]);
    ca53_probe(dcu_pa_dc3[39:0]);
    ca53_probe(ns_dsc_dc3);
    ca53_probe(attrs_dc3[7:0]);
    ca53_probe(dcu_wpt_hit_dc3);
    ca53_probe(dcu_strex_okay_dc3);
    ca53_probe(dcu_p_abort_dc3);
    ca53_activate(cpiid2, longint'($time));
  end

integer cpiid3;
always @(posedge tarmac_enable)
begin
  cpiid3 = ca53_declare("CiJ1bml2ZW50LmNvcnRleGE1My5JbnNlcnRGb3JjZW9wUmV0EhcKD2luc3RyX2NvdW50X3JldCIECEAQABIWCg5leHB0X3Nsb3QxX3JldCIECAEQARIaChJleGNlcHRpb25fbW9kZV9yZXQiBAgFEAISHQoVbnh0X2Nwc3JfdGJpdF9yZXRfcHJlIgQIARADEhYKDmZvcmNlb3BfcGNfcmV0IgQIQBAEEhYKDmV4cHRfcmVzZXRfcmV0IgQIARAFEhQKDGV4cHRfZmlxX3JldCIECAEQBhIVCg1leHB0X3ZmaXFfcmV0IgQIARAHEhQKDGV4cHRfaXJxX3JldCIECAEQCBIVCg1leHB0X3ZpcnFfcmV0IgQIARAJEhoKEmV4cHRfaW1wcmVjaXNlX3JldCIECAEQChIbChNleHB0X3ZpbXByZWNpc2VfcmV0IgQIARALEhkKEWV4cHRfZXh0X2hhbHRfcmV0IgQIARAMEhoKEmV4cHRfb3N1Y19oYWx0X3JldCIECAEQDRIbChNleHB0X2VjY19yZWV4ZWNfcmV0IgQIARAOEhYKDmVudGVyX2hhbHRfcmV0IgQIARAPGgJYBA==");
end


always @(posedge clk)
  if (insert_forceop_ret & tarmac_enable)
  begin
    ca53_probe(instr_count_f4[63:0]);
    ca53_probe(expt_slot1_ret);
    ca53_probe(exception_mode_ret[4:0]);
    ca53_probe(nxt_cpsr_tbit_ret_pre);
    ca53_probe(forceop_pc_ret[63:0]);
    ca53_probe(expt_reset_ret);
    ca53_probe(expt_fiq_ret);
    ca53_probe(expt_vfiq_ret);
    ca53_probe(expt_irq_ret);
    ca53_probe(expt_virq_ret);
    ca53_probe(expt_imprecise_ret);
    ca53_probe(expt_vimprecise_ret);
    ca53_probe(expt_ext_halt_ret);
    ca53_probe(expt_osuc_halt_ret);
    ca53_probe(expt_ecc_reexec_ret);
    ca53_probe(enter_halt_ret);
    ca53_activate(cpiid3, longint'($time));
  end

integer cpiid4;
always @(posedge tarmac_enable)
begin
  cpiid4 = ca53_declare("Ch91bml2ZW50LmNvcnRleGE1My5UcmFjZUludFJlZ1dyEhYKDmluc3RyX2NvdW50X3dyIgQIQBAAEhkKEXZhbGlkX2luc3Ryc193cl8xIgQIARABEhMKC3cwX3Nsb3QxX3dyIgQIARACEhYKDnJmX3dyX2VuX3cwX3dyIgQIARADEhYKDnJmX3dyX2VuX3cxX3dyIgQIARAEEhYKDnJmX3dyX2VuX3cyX3dyIgQIARAFEhcKD3JmX3dyXzY0Yl93MF93ciIECAEQBhIXCg9yZl93cl82NGJfdzFfd3IiBAgBEAcSFwoPcmZfd3JfNjRiX3cyX3dyIgQIARAIEhYKDnJmX3dyX2VuX2hpX3dyIgQIARAJEhgKEHJmX3dyX2FkZHJfdzBfd3IiBAgGEAoSGAoQcmZfd3JfYWRkcl93MV93ciIECAYQCxIYChByZl93cl9hZGRyX3cyX3dyIgQIBhAMEhgKEHJmX3dyX2RhdGFfdzBfd3IiBAhAEA0SGAoQcmZfd3JfZGF0YV93MV93ciIECEAQDhIYChByZl93cl9kYXRhX3cyX3dyIgQIQBAPEhgKEGZvcmNlb3BfdmFsaWRfd3IiBAgBEBASIgoacmZfd3JfZW5fdzBfdW5zdXByZXNzZWRfd3IiBAgBEBESIgoacmZfd3JfZW5fdzFfdW5zdXByZXNzZWRfd3IiBAgBEBISFgoOZmx1c2hlZF9kaXZfd3IiBAgBEBMSEgoKZW5fcmVzdG9yZSIECAEQFBoCWAU=");
end


always @(posedge clk)
  if (int_reg_wr_sample & tarmac_enable)
  begin
    ca53_probe(instr_count_wr[63:0]);
    ca53_probe(valid_instrs_wr[1]);
    ca53_probe(w0_slot1_wr);
    ca53_probe(rf_wr_en_w0_wr);
    ca53_probe(rf_wr_en_w1_wr);
    ca53_probe(rf_wr_en_w2_wr);
    ca53_probe(rf_wr_64b_w0_wr);
    ca53_probe(rf_wr_64b_w1_wr);
    ca53_probe(rf_wr_64b_w2_wr);
    ca53_probe(rf_wr_en_hi_wr);
    ca53_probe(rf_wr_addr_w0_wr[5:0]);
    ca53_probe(rf_wr_addr_w1_wr[5:0]);
    ca53_probe(rf_wr_addr_w2_wr[5:0]);
    ca53_probe(rf_wr_data_w0_wr[63:0]);
    ca53_probe(rf_wr_data_w1_wr[63:0]);
    ca53_probe(rf_wr_data_w2_wr[63:0]);
    ca53_probe(forceop_valid_wr);
    ca53_probe(rf_wr_en_w0_unsupressed_wr);
    ca53_probe(rf_wr_en_w1_unsupressed_wr);
    ca53_probe(flushed_div_wr);
    ca53_probe(en_restore);
    ca53_activate(cpiid4, longint'($time));
  end

integer cpiid5;
always @(posedge tarmac_enable)
begin
  cpiid5 = ca53_declare("CiN1bml2ZW50LmNvcnRleGE1My5UcmFjZUV4cHRTeXNSZWdXchIXCg9pbnN0cl9jb3VudF9yZXQiBAhAEAASEQoDaHNyEgQIARABIgQIIBACEhUKB2Vzcl9lbDISBAgBEAMiBAggEAQSEwoFaHBmYXISBAgBEAUiBAggEAYSFAoGZGZzcl9zEgQIARAHIgQIIBAIEhUKB2Rmc3JfbnMSBAgBEAkiBAggEAoSFQoHZXNyX2VsMRIECAEQCyIECCAQDBIVCgdlc3JfZWwzEgQIARANIgQIIBAOEhQKBmlmc3JfcxIECAEQDyIECCAQEBIVCgdpZnNyX25zEgQIARARIgQIIBASEhUKB2Zhcl9lbDESBAgBEBMiBAhAEBQSFQoHZGZhcl9ucxIECAEQFSIECCAQFhIVCgdpZmFyX25zEgQIARAXIgQIIBAYEhUKB2Zhcl9lbDISBAgBEBkiBAhAEBoSEwoFaGRmYXISBAgBEBsiBAggEBwSEwoFaGlmYXISBAgBEB0iBAggEB4SFAoGZGZhcl9zEgQIARAfIgQIIBAgEhQKBmlmYXJfcxIECAEQISIECCAQIhIVCgdmYXJfZWwzEgQIARAjIgQIQBAkEhEKA3NjchIECAEQJSIECCAQJhIVCgdoY3JfZWwyEgQIARAnIgQIQBAoGgJYBg==");
end


always @(posedge clk)
  if (expt_sys_reg_sample & tarmac_enable)
  begin
    ca53_probe(instr_count_f4[63:0]);
    ca53_probe(expt_en_hsr_ret);
    ca53_probe(nxt_cp_esr_el2_ret[31:0]);
    ca53_probe(expt_en_esr_el2_ret);
    ca53_probe(nxt_cp_esr_el2_ret[31:0]);
    ca53_probe(expt_en_hpfar_ret);
    ca53_probe(nxt_cp_hpfar_rd_ret[31:0]);
    ca53_probe(expt_en_dfsr_s_ret);
    ca53_probe(expt_dfsr_full_ret[31:0]);
    ca53_probe(expt_en_dfsr_ns_ret);
    ca53_probe(expt_dfsr_full_ret[31:0]);
    ca53_probe(expt_en_esr_el1_ret);
    ca53_probe(nxt_cp_esr_el1_ret[31:0]);
    ca53_probe(expt_en_esr_el3_ret);
    ca53_probe(nxt_cp_esr_el3_ret[31:0]);
    ca53_probe(expt_en_ifsr_s_ret);
    ca53_probe(nxt_ifsr_s_rd_ret[31:0]);
    ca53_probe(expt_en_ifsr_ns_ret);
    ca53_probe(nxt_ifsr_ns_rd_ret[31:0]);
    ca53_probe(expt_en_far_el1_ret);
    ca53_probe(nxt_cp_far_el1_ret[63:0]);
    ca53_probe(expt_en_dfar_ns_ret);
    ca53_probe(nxt_dfar_ns_ret[31:0]);
    ca53_probe(expt_en_ifar_ns_ret);
    ca53_probe(nxt_ifar_ns_ret[31:0]);
    ca53_probe(expt_en_far_el2_ret);
    ca53_probe(nxt_cp_far_el2_ret[63:0]);
    ca53_probe(expt_en_hdfar_ret);
    ca53_probe(nxt_hdfar_ret[31:0]);
    ca53_probe(expt_en_hifar_ret);
    ca53_probe(nxt_hifar_ret[31:0]);
    ca53_probe(expt_en_dfar_s_ret);
    ca53_probe(nxt_dfar_s_ret[31:0]);
    ca53_probe(expt_en_ifar_s_ret);
    ca53_probe(nxt_ifar_s_ret[31:0]);
    ca53_probe(expt_en_far_el3_ret);
    ca53_probe(nxt_far_el3_ret[63:0]);
    ca53_probe(expt_en_scr_ret);
    ca53_probe(nxt_scr_ret[31:0]);
    ca53_probe(expt_en_hcr_el2_ret);
    ca53_probe(nxt_hcr_el2_ret[63:0]);
    ca53_activate(cpiid5, longint'($time));
  end

integer cpiid6;
always @(posedge tarmac_enable)
begin
  cpiid6 = ca53_declare("CiV1bml2ZW50LmNvcnRleGE1My5UcmFjZUF0c1BhclVwZGF0ZVdyEhcKD2RjdV9jcF9yZWdfZGF0YSIECAEQABoCWAc=");
end


always @(posedge clk)
  if (ats_par_sample & tarmac_enable)
  begin
    ca53_probe(dcu_cp_reg_data);
    ca53_activate(cpiid6, longint'($time));
  end

integer cpiid7;
always @(posedge tarmac_enable)
begin
  cpiid7 = ca53_declare("CiB1bml2ZW50LmNvcnRleGE1My5Gb3JjZW9wVmFsaWRXchoCWAg=");
end


always @(posedge clk)
  if (forceop_valid_wr & tarmac_enable)
  begin
    ca53_activate(cpiid7, longint'($time));
  end

integer cpiid8;
always @(posedge tarmac_enable)
begin
  cpiid8 = ca53_declare("Ch91bml2ZW50LmNvcnRleGE1My5UcmFjZUZwdVJlZ1dyEhYKDmluc3RyX2NvdW50X2Y1IgQIQBAAEhcKD3JmX3dyX2VuX2Z3MF9mNSIECAQQARIXCg9yZl93cl9lbl9mdzFfZjUiBAgEEAISGQoRcmZfd3JfYWRkcl9mdzBfZjUiBAgGEAMSGQoRcmZfd3JfYWRkcl9mdzFfZjUiBAgGEAQSGQoRcmZfd3JfZGF0YV9mdzBfZjUiBAhAEAUSGQoRcmZfd3JfZGF0YV9mdzFfZjUiBAhAEAYSHAoUdW5mbHVzaGFibGVfc2ZkaXZfZjUiBAgBEAcSIgoUc2ZtYWNfaW5zdHJfY291bnRfZjUSBAgBEAgiBAhAEAkSHAoUdW5mbHVzaGFibGVfc2ZtYWNfZjUiBAgBEAoSGgoMbnh0X2ZwZXhjX2Y1EgQIARALIgQIIBAMGgJYCQ==");
end


always @(posedge clk)
  if (fpu_reg_wr_sample & tarmac_enable)
  begin
    ca53_probe(instr_count_f5[63:0]);
    ca53_probe(rf_wr_en_fw0_f5[3:0]);
    ca53_probe(rf_wr_en_fw1_f5[3:0]);
    ca53_probe(rf_wr_addr_fw0_f5[5:0]);
    ca53_probe(rf_wr_addr_fw1_f5[5:0]);
    ca53_probe(rf_wr_data_fw0_f5[63:0]);
    ca53_probe(rf_wr_data_fw1_f5[63:0]);
    ca53_probe(unflushable_sfdiv_f5);
    ca53_probe(unflushable_sfmac_f5);
    ca53_probe(sfmac_instr_count_f5[63:0]);
    ca53_probe(unflushable_sfmac_f5);
    ca53_probe(en_fpexc_reg_f5);
    ca53_probe(nxt_fpexc_f5[31:0]);
    ca53_activate(cpiid8, longint'($time));
  end

integer cpiid9;
always @(posedge tarmac_enable)
begin
  cpiid9 = ca53_declare("CiV1bml2ZW50LmNvcnRleGE1My5VbmZsdXNoYWJsZVNmbWFjSXNzEhYKDmluc3RyX2NvdW50X2Y0IgQIQBAAGgJYCg==");
end


always @(posedge clk)
  if (sample_unflushable_sfmac_iss & tarmac_enable)
  begin
    ca53_probe(instr_count_f4[63:0]);
    ca53_activate(cpiid9, longint'($time));
  end

integer cpiid10;
always @(posedge tarmac_enable)
begin
  cpiid10 = ca53_declare("Ch91bml2ZW50LmNvcnRleGE1My5UcmFjZVN5c1JlZ1dyEhYKDmluc3RyX2NvdW50X3dyIgQIQBAAEhoKDGRwdV9jcF9vcF93chIECAEQASIECAkQAhIiChByYXdfY3BfZGVjb2RlX3dyEggIAXIECAEQAyIECAgQBBITCgttY3JfZGF0YV93ciIECEAQBRISCgpsc19zaXplX3dyIgQIAhAGEg4KBm5zX3NjciIECAEQBxITCgt0dGJjcl9lYWVfcyIECAEQCBIUCgx0dGJjcl9lYWVfbnMiBAgBEAkaAlgL");
end


always @(posedge clk)
  if (sys_reg_wr_sample & tarmac_enable)
  begin
    ca53_probe(instr_count_wr[63:0]);
    ca53_probe(dpu_ready_wr);
    ca53_probe(dpu_cp_op_wr[8:0]);
    ca53_probe(dpu_ready_wr);
    ca53_probe(raw_cp_decode_wr[7:0]);
    ca53_probe(mcr_data_wr[63:0]);
    ca53_probe(ls_size_wr[1:0]);
    ca53_probe(ns_scr);
    ca53_probe(ttbcr_eae_s);
    ca53_probe(ttbcr_eae_ns);
    ca53_activate(cpiid10, longint'($time));
  end

integer cpiid11;
always @(posedge tarmac_enable)
begin
  cpiid11 = ca53_declare("Ch51bml2ZW50LmNvcnRleGE1My5JbnN0ckVuZGVkRjUSGwoTaW5zdHJfZG9uZV9jb3VudF9mNSIECEAQABoCWAw=");
end


always @(posedge clk)
  if (instr_ended_f5_sample & tarmac_enable)
  begin
    ca53_probe(instr_done_count_f5[63:0]);
    ca53_activate(cpiid11, longint'($time));
  end

integer cpiid12;
always @(posedge tarmac_enable)
begin
  cpiid12 = ca53_declare("Chx1bml2ZW50LmNvcnRleGE1My5UcmFjZVBzcldyEh8KEW54dF9jcHNyX3JldF9mdWxsEgQIARAAIgQIIBABEhsKDXNwc3Jfc3ZjX2Z1bGwSBAgBEAIiBAggEAMSGwoNc3Bzcl9hYnRfZnVsbBIECAEQBCIECCAQBRIbCg1zcHNyX3VuZF9mdWxsEgQIARAGIgQIIBAHEhsKDXNwc3JfaXJxX2Z1bGwSBAgBEAgiBAggEAkSGwoNc3Bzcl9maXFfZnVsbBIECAEQCiIECCAQCxIbCg1zcHNyX21vbl9mdWxsEgQIARAMIgQIIBANEhsKDXNwc3JfaHlwX2Z1bGwSBAgBEA4iBAggEA8aAlgN");
end


always @(posedge clk)
  if (psr_sample & tarmac_enable)
  begin
    ca53_probe(cpsr_regfile_en_wr);
    ca53_probe(nxt_cpsr_ret_full[31:0]);
    ca53_probe(spsr_svc_sample);
    ca53_probe(spsr_svc_full[31:0]);
    ca53_probe(spsr_abt_sample);
    ca53_probe(spsr_abt_full[31:0]);
    ca53_probe(spsr_und_sample);
    ca53_probe(spsr_und_full[31:0]);
    ca53_probe(spsr_irq_sample);
    ca53_probe(spsr_irq_full[31:0]);
    ca53_probe(spsr_fiq_sample);
    ca53_probe(spsr_fiq_full[31:0]);
    ca53_probe(spsr_mon_sample);
    ca53_probe(spsr_mon_full[31:0]);
    ca53_probe(spsr_hyp_sample);
    ca53_probe(spsr_hyp_full[31:0]);
    ca53_activate(cpiid12, longint'($time));
  end

integer cpiid13;
always @(posedge tarmac_enable)
begin
  cpiid13 = ca53_declare("Ch51bml2ZW50LmNvcnRleGE1My5SZXNldFJlbW92ZWQSDgoGY3B1X2lkIgQIAhAAEhkKEWdvdl9jbHVzdGVyaWRhZmYxIgQICBABEhkKEWdvdl9jbHVzdGVyaWRhZmYyIgQICBACGgJYDg==");
end


always @(posedge reset_n)
  if (tarmac_enable)
  begin
    ca53_probe(cpu_id[1:0]);
    ca53_probe(gov_clusteridaff1[7:0]);
    ca53_probe(gov_clusteridaff2[7:0]);
    ca53_activate(cpiid13, longint'($time));
  end

