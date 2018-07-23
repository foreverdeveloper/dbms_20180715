ERWin 7.3 r2 기준
	Tools > Reverse Engineer
		New Model Type: Logical/Physical 선택
		Target Database : Oracle , Version : 10.x/11.x
	후, Next

	Reverse Engineer - Set Options
		Reverse Engineer From : 	Database 체크
		Tables/Views Owned By :  Owners (comma separated) 체크
			: hr
	후, Next

	Oracle Connection
		Database : Oracle 10g/11g
		Authentication : Database Authentication
		User Name :  SYSTEM (SYS 계정 불가)
		Password :	orclBimil*30

		Connection String : localhost:1521/orcl

	------------------------------------------------------
	Unable to locate client connectivity software ora7nt.dll.
	Check with your Oracle database administrator
	to install the appropriate client software. - 오라클 클라이언트 설치 요함
	------------------------------------------------------//


물리적인 주석을 논리적인 컬럼명으로 사용
	1. Logical/Physical 을 분리 (Ctrl + Up/Down)
		Physical 상태에서 Ctrl + A 로 전체 선택 후, 마우스 우측 Harden Physical Names 선택

	2. Physical 을 Logical로 변경 (Ctrl + Up/Down)
		Model > Domain Dictionary...
		Edit Mode가 Logical인지 확인을 한 후
		Name Inherited by Attribute:* : %ColumnComment
			로 직접 입력 혹은
			Macro Toobox 버튼을 클릭 후, 좌측 Attribute Macro > %ColumnComment 을
			선택한 후, Insert Macro 클릭 후, Close 하여 입력할 수 있다.

    		참고 (공백 주석의 경우, 컬럼이름으로 입력하도록 함.):
    			%if(%>(%Len(%ColumnComment),0)){%ColumnComment}%ELSE{%ColName}

		Model - Attributes.. 를 선택 합니다. (계속 Logical 모드임)
		Reset 을 누릅니다.
		Resetting Attribute : Reset all attributes in model  (ERD 전체 변경)
		Clear All 버튼 클릭 후,
		Select Properties to Reset : Name
		만 체크한다.





