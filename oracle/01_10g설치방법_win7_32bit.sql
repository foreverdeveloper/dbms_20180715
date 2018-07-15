제품 설치 전 사전 설치 작업
	하드웨어 요구 사항
		RAM : 최소 256MB, 권장 512MB
		가상 메모리: RAM 크기의 2배
		디스크 공간 : 2G
		프로세서: 최소 550MHz 이상

Oracle Universal Installer를 이용한 설치
	1. 루프백 어뎁터를 설치한다 - 개인 PC용

	제품별 필요 조건 검사
		네트워크 구성 요구 사항을 확인하는 중... - 실행되지 않음. 혹은 경고
			Microsoft LoopBack Adpator를 시스템의 기본 네트워크 어댑터로 구성
			---------------------------------------------------
			제어판 > 장치 관리자 > 동작 > 레거시 하드웨어 추가
			목록에서 직접선택한 하드웨어 설치(고급)
			네트워크 어댑터
			Microsoft - Microsoft LoopBack Adapter 설치

			어뎁터 설정 변경
			로컬 영역 연결 2
					속성
						IP : 192.168. 10. 10
						S/M: 255.255.255.0
						GW : 10.10.10.10
			시스템 속성 > 내컴퓨터 이름 체크 - NOODLEWORK32
			컴퓨터 재시작
			C:\Windows\System32\drivers\etc\host 파일에
				192.168.10.10	컴퓨터 전체이름 		컴퓨터 이름
				192.168.10.10	NOODLEWORK32
			---------------------------------------------------////

	2.
		setup.exe를 클릭하여 설치한다.
		Oracle 홈 위치 : C:\oracle\product\10.2.0\db_1
		설치 유형: Enterprise Edition
		전역 데이터베이스 이름: orcl
		암호: orclBimil*30 을 입력한다.

	3.	암호관리
		SYS		- 관리자와 동일
		SYSTEM	- 관리자와 동일
		의 암호와
		HR		- P@ssw0rds
		OE	- P@ssw0rds
		SH		- P@ssw0rds
		등 계정을 풀고, 암호를 설정한다.

	설치 후 메시지
	------------------------------------------------------
	Enterprise Manager 데이터베이스 컨트롤 URL - (orcl) :
	http://NOODLEWORK32:1158/em

	데이터베이스 구성 파일은 C:\oracle\product\10.2.0에 설치되었으며 설치 시 선택한 다른 구성 요소는 C:\oracle\product\10.2.0\db_1에 설치되었습니다. 실수로 이들 구성 파일을 삭제하지 않도록 주의하십시오.
	iSQL*Plus URL:
	http://NOODLEWORK32:5560/isqlplus

	iSQL*Plus DBA URL:
	http://NOODLEWORK32:5560/isqlplus/dba
	------------------------------------------------------////

	5.  EM 사용 - 웹에서 쿼리하기
		http://localhost:1158/em
		hr로 접속해본다.

	6. SQLPLUS 사용 - 명령창 이용
		cmd> sqlplus hr
		SQL> 	SELECT * FROM TAB;

