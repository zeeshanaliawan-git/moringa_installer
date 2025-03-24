-----------Start 6 Sep 2022 Ahsan---------------
ALTER TABLE process_form_lines DROP primary KEY;
ALTER TABLE process_form_lines add primary KEY(form_id,id);
-----------End 6 Sep 2022 Ahsan---------------