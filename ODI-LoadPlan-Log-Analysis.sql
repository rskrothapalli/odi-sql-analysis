WITH lp AS
  (SELECT lps.I_LP_STEP,
    REPLACE(lps.LP_STEP_NAME,' ','_') LP_STEP_NAME,
    lps.PAR_I_LP_STEP,
   lpsl.START_DATE START_DATE,
    CASE
      WHEN lpsl.SESS_NO IS NULL
      THEN lpsl.END_DATE
      ELSE
        (SELECT scnr.SESS_END
        FROM SNP_SCEN_REPORT scnr
        WHERE scnr.SCEN_RUN_NO = lpsl.SESS_NO
        )
    END END_DATE,
    lps.STEP_ORDER,
    lps.SCEN_NAME
  FROM SNP_LP_STEP lps
  INNER JOIN SNP_LPI_STEP_LOG lpsl
  ON lps.I_LP_STEP     = lpsl.I_LP_STEP
  WHERE lpsl.I_LP_INST = -- <<LoadPlanNumber>>
  ORDER BY lpsl.I_LP_STEP
  )
SELECT
  TRIM(LEADING ';' FROM SYS_CONNECT_BY_PATH(lp.LP_STEP_NAME,';')) STEP_PATH, 
  (lp.END_DATE - lp.START_DATE)*86400 DURATION
FROM lp
  START WITH lp.I_LP_STEP     = -- <<LoadPlanFirstStep>>
  CONNECT BY lp.PAR_I_LP_STEP = PRIOR lp.I_LP_STEP ;
