 프로파일링 
 	데이터 품질 측정 대상 데이터베이스의 데이터를 읽어 
 	컬럼, 테이블의 데이터 현황정보를 통계적으로 분석하는 것
 	-> 오류 데이터 후보 선정과 업무 규칙 대상 선정

----------------------------------------------------------------------
1. 미사용 테이블을 찾기 위한 SQL Monitoring
----------------------------------------------------------------------

 다음의 SQL을 실행하고 매 5분 단위로 실행하고 그 결과를 file에 저장하면 됩니다. file format은 csv file format이 가장 적절할 것 같습니다. 하지만 특정 구분자로 구성된 어떤 file 형태도 무관합니다.
 
 SQL을 실행하기 위해서는 v$session, v$access, v$sql 테이블에 대한 SELECT 권한이 필요합니다.

SELECT 
 a.sid, a.username, a.machine, a.terminal, c.address, c.last_active_time,
 c.last_load_time. c.sql_text
FROM
 v$session a, v$access b, v$sql c
WHERE
 a.service_name = c.service_name AND a.sid = b.sid AND
 a.prev_sql_id = c.sql_id AND c.service = a.service_name AND
 a.username = [User_Name] ;

----------------------------------------------------------------------//


----------------------------------------------------------------------
2. 데이터 구조 및 값의 분포를 조사하기 위한 SQL

번호		테이블명		컬럼명	순서		자료형	길이		정밀도	NULL여부		기본값	설명		
전체레코드수		최대값	평균값	최소값	최대길이	평균길이	
최소길이		유일값수		NULL값수		최대빈도값	최소빈도값	1/4분위수	3/4분위수	
표준편차		분산
----------------------------------------------------------------------//

 이 활동은 한번만 수행하면 됩니다. 
 별도의 DBA 권한이나 시스템 테이블 접근 권한이 필요하지 않고 모든 테이블에 접근
 (SELECT) 가능한 응용 프로그램 개발자 권한만 있으면 됩니다.

 
SELECT
  ROWNUM  AS    "번호",
  T.TABLE_NAME  AS  "테이블명",
  T.COLUMN_NAME  AS  "컬럼명",
  T.COLUMN_ID  AS  "순서",
  T.DATA_TYPE  AS  "자료형",
  T.DATA_LENGTH  AS  "길이",
  T.DATA_PRECISION  AS  "정밀도",
  DECODE(T.NULLABLE,  'N'  ,  'NOT  NULL'  ,  'Y',  '  ')  "널허용",
  T.DATA_DEFAULT  AS  "기본값",
  C.COMMENTS  AS  "코멘트"
FROM
  ALL_TAB_COLS  T  ,  ALL_COL_COMMENTS  C
WHERE
  T.OWNER  =  C.OWNER  AND
  T.TABLE_NAME  =  C.TABLE_NAME  AND
  T.COLUMN_NAME  =  C.COLUMN_NAME  AND
  T.OWNER  =  '[이용자]'
ORDER  BY  T.TABLE_NAME,  T.COLUMN_ID  ASC  ;

--//분석  데이터  수집을  위한  SQL//--

--//①  전체레코드수,  최대값,  최소값,  최대길이,  최소길이  등//--
SELECT  
  COUNT([컬럼]) AS "전체레코드수",  
  MAX([컬럼]) AS "최대값",  
  -- AVG([컬럼]) AS "평균값", 			-- 문자의 경우는 평균값이 존재하지 않음.
  MIN([컬럼]) AS "최소값",
  MAX(LENGTH([컬럼])) AS "최대길이",  
  AVG(LENGTH([컬럼])) AS "평균길이",
  MIN(LENGTH([컬럼])) AS "최소길이",
FROM      [테이블]  ;

--//②  유일한  값  개수//--
SELECT  DISTINCT  COUNT([컬럼]) 
FROM [테이블]  ;

--//③  NULL  값  개수//--
SELECT  COUNT([컬럼]) 
FROM      [테이블]
WHERE  [컬럼]  IS  NULL  ;

--//④  최대빈도값,  최소빈도값//--
SELECT  [대상컬럼],  CNT
FROM
  (SELECT    [대상컬럼],  COUNT([대상컬럼])  as  CNT
   FROM      [대상테이블]
   GROUP  BY  [대상컬럼]
   ORDER  BY  CNT  DESC           /*  DESC:최대빈도,  ASC:최소빈도  */  )
WHERE  ROWNUM  <=  [개수]  ;
*  [개수]는  최대  빈도가  높은  것을  몇  개까지  추출할  것인가를  의미

-------------------------------------------------------------------------------------//


-------------------------------------------------------------------------------------
엑셀 출력을 위한 종합 쿼리 작성 
-------------------------------------------------------------------------------------
DECLARE 
    CURSOR cur_tab_cols ( cp_USER ALL_TAB_COLS.OWNER%TYPE )
    IS 
        SELECT
          ROWNUM  AS    "번호",
          T.TABLE_NAME  AS  "테이블명",
          T.COLUMN_NAME  AS  "컬럼명",
          T.COLUMN_ID  AS  "순서",
          T.DATA_TYPE  AS  "자료형",
          T.DATA_LENGTH  AS  "길이",
          T.DATA_PRECISION  AS  "정밀도",
          DECODE(T.NULLABLE,  'N'  ,  'NOT  NULL'  ,  'Y',  '  ')  "NULL여부",
          T.DATA_DEFAULT  AS  "기본값",
          C.COMMENTS  AS  "설명"
        FROM
          ALL_TAB_COLS  T  ,  ALL_COL_COMMENTS  C
        WHERE
          T.OWNER  =  C.OWNER  AND
          T.TABLE_NAME  =  C.TABLE_NAME  AND
          T.COLUMN_NAME  =  C.COLUMN_NAME  AND
        --  T.OWNER  =  '[이용자]'
          T.OWNER  =  cp_USER    -- 이용자 매개변수 받음
        ORDER  BY  1, T.TABLE_NAME,  T.COLUMN_ID  ASC  ;

    v_sql VARCHAR2(1000) := '';

    v_col_total_cnt NUMBER;
    v_col_max       VARCHAR2(200);
    v_col_avg       VARCHAR2(200);    -- 문자형의 경우, 평균값은 존재하지 않음.
    v_col_min       VARCHAR2(200);
    v_col_max_len   NUMBER;
    v_col_avg_len   NUMBER;
    v_col_min_len   NUMBER;
    ------------------------------------------
    v_col_distinct_cnt    NUMBER;
    ------------------------------------------
    v_col_null_cnt		NUMBER;
    ------------------------------------------
BEGIN
    FOR tab_cols IN cur_tab_cols('HR')
    LOOP
        /*
SELECT  
  COUNT([컬럼]) AS "전체레코드수",  
  MAX([컬럼]) AS "최대값",  
  AVG([컬럼]) AS "평균값",
  MIN([컬럼]) AS "최소값",
  MAX(LENGTH([컬럼])) AS "최대길이",  
  AVG(LENGTH([컬럼])) AS "평균길이",
  MIN(LENGTH([컬럼])) AS "최소길이",
FROM      [테이블]  ;

        */
        v_sql := 

        'SELECT  ' ||
        ' COUNT(        ' || tab_cols."컬럼명" || '),   ' ||          
        ' MAX(            ' || tab_cols."컬럼명" || '),   ' ||   
        --' AVG(            ' || tab_cols."컬럼명" || '),   ' || 
        ' MIN(            ' || tab_cols."컬럼명" || ')    ,   ' || 
        ' MAX(LENGTH(    ' || tab_cols."컬럼명" || ')),   ' ||    
        ' AVG(LENGTH(    ' || tab_cols."컬럼명" || ')),   ' ||    
        ' MIN(LENGTH(    ' || tab_cols."컬럼명" || '))   ' ||    
        ' FROM HR.' || tab_cols."테이블명" 
        ;
        --DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);

        EXECUTE IMMEDIATE v_sql INTO 
            v_col_total_cnt,      -- 전체레코드수
            v_col_max,          -- 최대값
            -- v_col_avg,            -- 평균값
            v_col_min,            -- 최소값
            v_col_max_len,      -- 최대길이
            v_col_avg_len,        -- 평균길이
            v_col_min_len        -- 최소길이
        ;

/*
--//②  유일한  값  개수//--
SELECT  DISTINCT  COUNT([컬럼]) 
FROM [테이블]  ;

*/        
        v_sql := 
        'SELECT  DISTINCT  COUNT( ' || tab_cols."컬럼명" || ')  ' ||
        ' FROM HR.' || tab_cols."테이블명" 
        ;
--        DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);
        EXECUTE IMMEDIATE v_sql INTO 
            v_col_distinct_cnt      -- 컬럼의 유일한 값 개수
        ;

/*
--//③  NULL  값  개수//--
SELECT  COUNT([컬럼]) 
FROM      [테이블]
WHERE  [컬럼]  IS  NULL  ;
*/
        v_sql := 
        'SELECT  COUNT( ' || tab_cols."컬럼명" || ')  ' ||
        ' FROM HR.' || tab_cols."테이블명"  ||
        ' WHERE ' || tab_cols."컬럼명" || ' IS NULL '
        ;
--        DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);
        EXECUTE IMMEDIATE v_sql INTO 
            v_col_null_cnt      -- 컬럼의 NULL값 개수
        ;

/*
SELECT  [대상컬럼],  CNT
FROM
  (SELECT    [대상컬럼],  COUNT([대상컬럼])  as  CNT
   FROM      [대상테이블]
   GROUP  BY  [대상컬럼]
   ORDER  BY  CNT  DESC          --  DESC:최대빈도,  ASC:최소빈도 
  )
WHERE  ROWNUM  <=  [개수]

*/


        DBMS_OUTPUT.PUT_LINE(tab_cols."번호"
            || ',' || tab_cols."테이블명"
            || ',' || tab_cols."컬럼명"
            || ',' || tab_cols."순서"
            || ',' || tab_cols."자료형"
            || ',' || tab_cols."길이"
            || ',' || tab_cols."정밀도"
            || ',' || tab_cols."NULL여부"
            || ',' || tab_cols."기본값"
            || ',' || tab_cols."설명"
            -----------------------------------------
            || ',' || v_col_total_cnt    --tab_cols."전체레코드수"
            || ',' || v_col_max     --tab_cols."최대값"
--            || ',' || v_col_avg     --tab_cols."평균값"
            || ',' || v_col_min          --tab_cols."최소값"
            || ',' || v_col_max_len      --tab_cols."최대길이"
            || ',' || v_col_avg_len          --tab_cols."평균길이"
            || ',' || v_col_min_len      --tab_cols."최소길이"
            -----------------------------------------
            || ',' || v_col_distinct_cnt      -- 컬럼의 유일한 값 개수
            -----------------------------------------
            || ',' || v_col_null_cnt      --컬럼의 NULL값 개수
            -----------------------------------------
            );


    END LOOP;
    
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SQL ERROR CODE: ' || SQLCODE)    ;
        DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE: ' || SQLERRM); -- 매개변수 없는 SQLERRM
        DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE)); -- 매개변수 있는 SQLERRM
        DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

END;



-------------------------------------------------------------------------------------//