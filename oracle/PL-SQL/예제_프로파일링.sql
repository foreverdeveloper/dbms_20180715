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

    v_tab_count NUMBER; -- 출력용 테이블을 존재 유무 체크

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
    v_col_null_cnt    NUMBER;
    ------------------------------------------
    v_max_freq_cnt    NUMBER;  -- 최대빈도
    v_min_freq_cnt    NUMBER;  -- 최소빈도
    ------------------------------------------
    v_q1_num    NUMBER;   -- 제 1 사분위수 Quartile   - 1/4분위수
    v_q3_num    NUMBER;   -- 제 3 사분위수 Quartile - 3/4분위수
    ------------------------------------------
    v_stddev      NUMBER;   -- 표준편차
    v_variance    NUMBER;   -- 분산 
    ------------------------------------------
BEGIN
DBMS_OUTPUT.DISABLE;
DBMS_OUTPUT.ENABLE(1000000);
    
    SELECT COUNT(*) INTO v_tab_count
    -- FROM USER_TABLES
    FROM ALL_TAB_COLS
    WHERE OWNER= 'HR' AND TABLE_NAME = 'TMP_PROFILING';
    
    DBMS_OUTPUT.PUT_LINE('v_tab_count ==>' || v_tab_count);

    IF v_tab_count > 0 THEN    
 
        v_sql:= ' DROP TABLE HR.TMP_PROFILING '; 
        DBMS_OUTPUT.PUT_LINE('== DROP : TMP_PROFILING ==');
        EXECUTE IMMEDIATE v_sql; 
    END IF;
 
    v_sql := ' CREATE TABLE HR.TMP_PROFILING ( ' || 
         '        "번호"        NUMBER ' ||
         '     ,  "테이블명"     VARCHAR2(200)     ' ||
         '     ,  "컬럼명"       VARCHAR2(200) ' ||
         '     ,  "순서"         NUMBER ' ||
         '     ,  "자료형"       VARCHAR2(200) ' ||
         '     ,  "길이"         NUMBER ' ||
         '     ,  "정밀도"       NUMBER ' ||
         '     ,  "NULL여부"    VARCHAR2(10)' ||
         '     ,  "기본값"      VARCHAR2(200)' ||  -- LONG
         '     ,  "설명"        VARCHAR2(4000) ' ||
         '     ,  "전체레코드수"    NUMBER ' ||
         '     ,  "최대값"    VARCHAR2(200)' ||
         '     ,  "평균값"    VARCHAR2(200)' ||
         '     ,  "최소값"    VARCHAR2(200)' ||
         '     ,  "최대길이"    NUMBER' ||
         '     ,  "평균길이"    NUMBER' ||
         '     ,  "최소길이"    NUMBER' ||
         '     ,  "유일값수"    NUMBER' ||
         '     ,  "NULL값수"    NUMBER' ||
         '     ,  "최대빈도값"   NUMBER ' ||
         '     ,  "최소빈도값"   NUMBER ' ||
         '     ,  "1/4분위수"    NUMBER ' ||
         '     ,  "3/4분위수"    NUMBER ' ||
         '     ,  "표준편차"      NUMBER' ||
         '     ,  "분산"        NUMBER ' ||
         '     ) ' ;

    DBMS_OUTPUT.PUT_LINE('== TMP_PROFILING ==' || v_sql );

    EXECUTE IMMEDIATE v_sql; 


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
        DBMS_OUTPUT.PUT_LINE('=============== 1 ================');
        v_sql :=

        'SELECT  ' ||
        ' COUNT(        ' || tab_cols."컬럼명" || '),   ' ||
        ' MAX(            ' || tab_cols."컬럼명" || '),   ' ||
        ' MIN(            ' || tab_cols."컬럼명" || ')    ,   ' ||
        ' MAX(LENGTH(    ' || tab_cols."컬럼명" || ')),   ' ||
        ' AVG(LENGTH(    ' || tab_cols."컬럼명" || ')),   ' ||
        ' MIN(LENGTH(    ' || tab_cols."컬럼명" || '))   ' ||
        ' FROM HR.' || tab_cols."테이블명"
        ;
        DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);

        EXECUTE IMMEDIATE v_sql INTO
            v_col_total_cnt,      -- 전체레코드수
            v_col_max,          -- 최대값
            v_col_min,            -- 최소값
            v_col_max_len,      -- 최대길이
            v_col_avg_len,        -- 평균길이
            v_col_min_len        -- 최소길이
        ;

        DBMS_OUTPUT.PUT_LINE('=============== 평균은 숫자형(현재 타입: ' ||
                            tab_cols."자료형" || ')만 고려 ================');
        IF tab_cols."자료형" IN ( 'NUMBER') THEN
          v_sql :=

            'SELECT  ' ||
            ' AVG(            ' || tab_cols."컬럼명" || ')   ' ||
            ' FROM HR.' || tab_cols."테이블명"
            ;
            DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);

            EXECUTE IMMEDIATE v_sql INTO
                v_col_avg           -- 평균값
            ;
        ELSE
          v_col_avg :=  NULL;
        END IF;


/*
--//②  유일한  값  개수//--
SELECT  DISTINCT  COUNT([컬럼])
FROM [테이블]  ;

*/
        DBMS_OUTPUT.PUT_LINE('=============== 2 ================');
        v_sql :=
        'SELECT  DISTINCT  COUNT( ' || tab_cols."컬럼명" || ')  ' ||
        ' FROM HR.' || tab_cols."테이블명"
        ;
        DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);
        EXECUTE IMMEDIATE v_sql INTO
            v_col_distinct_cnt      -- 컬럼의 유일한 값 개수
        ;

/*
--//③  NULL  값  개수//--
SELECT  COUNT([컬럼])
FROM      [테이블]
WHERE  [컬럼]  IS  NULL  ;
*/
        DBMS_OUTPUT.PUT_LINE('=============== 3 ================');
        v_sql :=
        'SELECT  COUNT( ' || tab_cols."컬럼명" || ')  ' ||
        ' FROM HR.' || tab_cols."테이블명"  ||
        ' WHERE ' || tab_cols."컬럼명" || ' IS NULL '
        ;
        DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);
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

참고:  [개수]는  최대  빈도가  높은  것을  몇  개까지  추출할  것인가를  의미

*/
        DBMS_OUTPUT.PUT_LINE('=============== 4 ================');
        v_sql :=
        'SELECT NVL(MAX(CNT),NULL) ' ||
        ' FROM ' ||
        ' ( ' ||
        '   SELECT ' || tab_cols."컬럼명" || ', COUNT( ' ||  tab_cols."컬럼명" || ') AS CNT' ||
        '   FROM HR.' || tab_cols."테이블명"  ||
        '   GROUP BY ' || tab_cols."컬럼명" ||
        '   ORDER BY CNT DESC ' ||
        ' ) ' ||
        ' WHERE ROWNUM <= 1 '
        ;
        DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);
        EXECUTE IMMEDIATE v_sql INTO
            v_max_freq_cnt      -- 최대빈도
        ;

        DBMS_OUTPUT.PUT_LINE('=============== 5 ================');
        v_sql :=
        'SELECT NVL(MAX(CNT),NULL) ' ||
        ' FROM ' ||
        ' ( ' ||
        '   SELECT ' || tab_cols."컬럼명" || ', COUNT( ' ||  tab_cols."컬럼명" || ') AS CNT' ||
        '   FROM HR.' || tab_cols."테이블명"  ||
        '   GROUP BY ' || tab_cols."컬럼명" ||
        '   ORDER BY CNT ASC ' ||
        ' ) ' ||
        ' WHERE ROWNUM <= 1 '
        ;
        DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);
        EXECUTE IMMEDIATE v_sql INTO
            v_min_freq_cnt     -- 최소빈도
        ;

        DBMS_OUTPUT.PUT_LINE('=============== 6. 1/4분위수는 숫자형(현재 타입: ' ||
                            tab_cols."자료형" || ')만 고려 ================');
        IF tab_cols."자료형" IN ( 'NUMBER') THEN
          v_sql :=
            'SELECT NVL(MAX(COL1), NULL) FROM ' ||
            '(' ||
            'SELECT  ' ||
            ' PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY ' || tab_cols."컬럼명" || ' ) OVER() AS COL1' ||
            ' FROM HR.' || tab_cols."테이블명" ||
            ' WHERE ROWNUM = 1 ' ||
            ')'
            ;
            DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);

            EXECUTE IMMEDIATE v_sql INTO
                v_q1_num            -- 제 1 사분위수  - 1/4분위수
            ;
        ELSE
          v_q1_num :=  NULL;
        END IF;

        DBMS_OUTPUT.PUT_LINE('=============== 7. 3/4분위수는 숫자형만 고려 ================');
        IF tab_cols."자료형" IN ( 'NUMBER') THEN
          v_sql :=
            'SELECT NVL(MAX(COL1), NULL) FROM ' ||
            '(' ||
            'SELECT  ' ||
            ' PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY ' || tab_cols."컬럼명" || ' ) OVER() AS COL1' ||
            ' FROM HR.' || tab_cols."테이블명" ||
            ' WHERE ROWNUM = 1 ' ||
            ')'            
            ;
            DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);

            EXECUTE IMMEDIATE v_sql INTO
                v_q3_num            -- 제 3 사분위수 - 3/4분위수
            ;
        ELSE
          v_q3_num :=  NULL;
        END IF;

        DBMS_OUTPUT.PUT_LINE('=============== 8. 표준편차 (숫자만 고려) ================');
        IF tab_cols."자료형" IN ( 'NUMBER') THEN
          v_sql :=

            'SELECT  ' ||
            ' STDDEV( ' || tab_cols."컬럼명" || ' ) ' ||
            ' FROM HR.' || tab_cols."테이블명" ||
            ' WHERE ROWNUM = 1 '
            ;
            DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);

            EXECUTE IMMEDIATE v_sql INTO
                v_stddev            -- 표준편차
            ;
        ELSE
          v_stddev :=  NULL;
        END IF;        

        DBMS_OUTPUT.PUT_LINE('=============== 9. 분산 (숫자만 고려) ===============');
        IF tab_cols."자료형" IN ( 'NUMBER') THEN
          v_sql :=

            'SELECT  ' ||
            ' VARIANCE(' || tab_cols."컬럼명" || ' ) ' ||
            ' FROM HR.' || tab_cols."테이블명" ||
            ' WHERE ROWNUM = 1 '
            ;
            DBMS_OUTPUT.PUT_LINE('v_sql ==> ' || v_sql);

            EXECUTE IMMEDIATE v_sql INTO
                v_variance            -- 분산
            ;
        ELSE
          v_variance :=  NULL;
        END IF;


        DBMS_OUTPUT.PUT_LINE(
            tab_cols."번호"
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
            || ',' || v_col_avg     --tab_cols."평균값"
            || ',' || v_col_min          --tab_cols."최소값"
            || ',' || v_col_max_len      --tab_cols."최대길이"
            || ',' || v_col_avg_len          --tab_cols."평균길이"
            || ',' || v_col_min_len      --tab_cols."최소길이"
            -----------------------------------------
            || ',' || v_col_distinct_cnt      -- 컬럼의 유일한 값 개수
            -----------------------------------------
            || ',' || v_col_null_cnt      --컬럼의 NULL값 개수
            -----------------------------------------
            || ',' || v_max_freq_cnt      -- 최대빈도
            || ',' || v_min_freq_cnt     -- 최소빈도
            -----------------------------------------
            || ',' || v_q1_num      -- 1/4분위수
            || ',' || v_q3_num      -- 최대빈도
            -----------------------------------------
            || ',' || v_stddev      -- 표준편차
            || ',' || v_variance      -- 분산
            );


      INSERT INTO HR.TMP_PROFILING(
       "번호", "테이블명", "컬럼명", 
       "순서", "자료형", "길이", 
       "정밀도", "NULL여부", "기본값", 
       "설명", "전체레코드수", "최대값", 
       "평균값", "최소값", "최대길이", 
       "평균길이", "최소길이", "유일값수", 
       "NULL값수", "최대빈도값", "최소빈도값", 
       "1/4분위수", "3/4분위수", "표준편차", 
       "분산") 
      VALUES (
        tab_cols."번호", tab_cols."테이블명", tab_cols."컬럼명"
        , tab_cols."순서", tab_cols."자료형", tab_cols."길이"
        , tab_cols."정밀도", tab_cols."NULL여부", tab_cols."기본값"
        , tab_cols."설명", v_col_total_cnt, v_col_max
        , v_col_avg, v_col_min , v_col_max_len
        , v_col_avg_len , v_col_min_len , v_col_distinct_cnt
        , v_col_null_cnt , v_max_freq_cnt, v_min_freq_cnt
        , v_q1_num , v_q3_num , v_stddev
        , v_variance
      );

    END LOOP;

    EXCEPTION WHEN OTHERS THEN
        NULL; -- 에러 무시 계속 진행 
        DBMS_OUTPUT.PUT_LINE('SQL ERROR CODE: ' || SQLCODE)    ;
        DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE: ' || SQLERRM); -- 매개변수 없는 SQLERRM
        DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE)); -- 매개변수 있는 SQLERRM
        DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

END;
-------------------------------------------------------------------------------------//