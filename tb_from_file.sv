integer fin_pointer,fout_pointer;
reg  usigned;
reg  [31:0] dividend,divisor;

task ee_se;
 begin

    fin_pointer= $fopen("../../../../tbench/se_ee_in.txt","r");
    if (fin_pointer==0)
    begin
       $display("Could not open file '%s' for reading","se_ee_in.txt");
       $stop;     
    end
    fout_pointer= $fopen("../../../../se_ee_out.txt","w");
    if (fout_pointer==0)
    begin
       $display("Could not open file '%s'  for writing","se_ee_out.txt");
       $stop;     
    end

//    @(posedge rst_n);
//    @(posedge clk);
    # 100;
    while (! $feof(fin_pointer)) begin
      $fscanf(fin_pointer,"%b %b %b\n",usigned,dividend,divisor);
//      valid=1;
//      @(posedge clk);
      #100 ; 
//      valid=0;
//      @(posedge res_ready);
      $fwrite(fout_pointer,"%b %b\n",~dividend,~divisor);
    end
    $finish;
    $fclose(fin_pointer);
    $fclose(fout_pointer);
end
endtask