SELECT DATCEN AS CalendarCentury,
       varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(DATBAK, 6, 0)), 'YYMMDD'), 'YYMMDD') AS Calendardate,
       DATPER AS MerchandisingPeriod,
       DATWKP AS WeeksintheMerchPd,
       DATWKY AS WeeksintheMerchYr,
       DATCYR AS MerchandisingYear,
       DATCDY AS DayofMerchandisingYear,
       DATDAY AS DayofMerchandisingWeek,
       DATLIT AS LiteralDateDescription,
       DATCCN AS MerchandisingCentury
    FROM MM4R4LIB.INVCAL