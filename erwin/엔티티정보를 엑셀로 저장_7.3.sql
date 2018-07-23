--------------------------------------------------------------------
ERD만 있고 테이블 정의서가 없을 때,

	Tools > Report Template Builder > Report Builder  메뉴 실행

	New 버튼 클릭

	Report Template Builder 다이알로그가 뜬다.

	좌측 Available Sections에서 Tables 섹션 선택한 후,
	> 버튼을 눌러 Report Layout 영역으로 선택함. 'Table' section 이 등록됨

	 'Table' section 에서 우클릭 Properties창을 띄움
	 	테이블 정의서에 출력할 내용을 선택한 후, 창을 닫는다.
		예)
			Table
				Filter: Name, Comment 체크
				Column :
					Sort By : Name, Comment, Is PK 체크
			한 후, 출력 순서를 조정 후, 닫는다.


	Report Template Builder 창에서 저장하여 ~.rtb 파일을 생성한 후 창을 닫는다.

	Report Templates 창에서 Output Type을 "TEXT"로 선택한 다음 "Run" 버튼을 눌러서 완성한다.
		NONE, HTML, RTF, TEXT, PDF

	TEXT를 선택하면, csv 파일로 저장된다.
--------------------------------------------------------------------//


--------------------------------------------------------------------
레포트 파일(*.erp)이 있는 경우 - 엔티티 정보를 엑셀 파일로 저장하기

Tools > Database Browser 로 Data Browser를 띄운다

Reports > Open Report File (*.erp 파일)
	적합한 레포트 파일을 연 후,
	All reports
	 >CA ERwin DM Reports > Table Reports > reportTableDef
	 	를 더블 클릭하면, 보고서(reportTableDef)가 생성된다.
		생성된 보고서를 우 클릭 후,  Export result set 'reportTableDef'

Export from Data browser 팝업이 뜬다.
	Export : 	CSV 를 선택
	Export하여 적합한 위치에 저장하면 된다.

--------------------------------------------------------------------

