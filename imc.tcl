load -run test
#load -run test_updt
config appearance.show_extend_metrics_tree -set true
config appearance.show_extend_metrics_tree -set true
#config reports.detachable_report_data -set true
csv_export -out ahb_apb_bridge.csv -cover -inst * -recursive -overwrite
#report -detail -text  -source on -out covreport.out -overwrite
report -detail  -source on -out covreport.out -overwrite -metrics all
#report_metrics -detail -source on -all -report_type extended -extended true -metrics all
report_metrics -detail  -all -out ahb_apb_bridge_report -title ahb_apb_bridge_cc -inst *
quit
