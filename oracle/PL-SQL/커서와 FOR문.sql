-- 가독성 고려한 선언과 FOR문 분리를 권장함
/*

기본 FOR 구문 형식
	FOR 인덱스 IN [REVERSE]초기값..최종값
	LOOP
		처리문;
	END LOOP;

*/

/*
커서와 함께 사용될 경우, FOR문 구문 형식	
	FOR 레코드 IN 커서명(매개변수1, 매개변수2, ...)
	LOOP
		처리문;
	END LOOP;
*/
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
		  T.OWNER  =  cp_USER	-- 이용자 매개변수 받음
		ORDER  BY  1, T.TABLE_NAME,  T.COLUMN_ID  ASC  ;
	
BEGIN
	FOR tab_cols IN cur_tab_cols('HR')
	LOOP
		DBMS_OUTPUT.PUT_LINE(tab_cols.번호);

	END LOOP;
	
END;


/*
커서와 함께 사용될 경우, FOR문 구문 형식 - 커서 정의 부분 생략 버전 (비권장)
	FOR 레코드 IN 커서명(매개변수1, 매개변수2, ...)
	LOOP
		처리문;
	END LOOP;
*/

DECLARE 

BEGIN
	FOR tab_cols IN (
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
		--  T.OWNER  =  cp_USER	-- 이용자 매개변수 받음
		 T.OWNER  =  'HR'	-- 이용자 매개변수 직접 지정 해야 함.
		ORDER  BY  1, T.TABLE_NAME,  T.COLUMN_ID  ASC  

		)
	LOOP
		DBMS_OUTPUT.PUT_LINE(tab_cols.번호);

	END LOOP;
	
END;
