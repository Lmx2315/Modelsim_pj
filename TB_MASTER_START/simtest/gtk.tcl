# clear all
set nfacs [ gtkwave::getNumFacs ]
set signals [list]
for {set i 0} {$i < $nfacs } {incr i} {
    set facname [ gtkwave::getFacName $i ]
    lappend signals "$facname"
}
gtkwave::deleteSignalsFromList $signals

# add instance port
set ports [list tb_cntr_module.clk tb_cntr_module.sync0 tb_cntr_module.sync1 tb_cntr_module.sync2 tb_cntr_module.rst tb_cntr_module.data0 tb_cntr_module.data1 tb_cntr_module.data2]
gtkwave::addSignalsFromList $ports
