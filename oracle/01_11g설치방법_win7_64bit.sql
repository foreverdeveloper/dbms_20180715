보안갱신 구성 :
	My Oracle Support를 통해 보안 갱신 수신 -  체크 풀기
설치옵션 : 데이터베이스 생성 및 구성
시스템 클래스: 서버 클래스
Grid설치옵션: 단일 인스턴스 디비 설치
설치유형: 고급 설치
제품언어: 영어,한국어
데이터베이스 버젼: Enterprise/Personal Edition
설치위치:
 Oracle Base: C:\app\noodlework
 소프트웨어 위치: C:\app\noodlework\product\11.2.0\dbhome_1
구성유형: 일반용/트랜잭션 처리
데이터베이스 식별자:
 전역 데이터베이스 이름: orcl + 버전 11g => orcl11g
 Oracle SID: orcl11g

구성옵션 :
	다음
관리옵션 :
	다음

데이터베이스 저장 영역:
 데이터베이스 파일 위치 지정:
   기본: C:\app\noodlework\oradata
   d:\oradata  혹은 c:\oradata
백업 및 복구
 자동 백업을 사용으로 설정하지 않음.
스키마 비밀번호:
 모든 계정에 동일한 비밀번호 사용
	orclBimil830  (orclBimil*30 입력하면 에러남)
...설치진행.....

비밀번호관리
 사용자 선별해서,  비밀번호 넣자(orapass)
--------------------//
시작 >Oracle - OraDb11g_home1
 >응용프로그램 개발
 >SQL Plus 실행
 system/orapass
 show user

▶유틸 호환을 위해 DeskTop엔 32bit 설치