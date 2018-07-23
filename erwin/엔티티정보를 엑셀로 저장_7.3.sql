Report Builder
--------------------------------------------------------------------
ERD만 있고 테이블 정의서가 없을 때,

	Tools > Report Template Builder > Report Builder  메뉴 실행 (*.rtb 파일로 생성됨)

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



Database Browser
--------------------------------------------------------------------
Report Template Builder는 파일로 내보내서 확인하는 방식이라면,
Database Browser는 데이터를 실제 보면서, 체크할 수 있는 잇점이 있음.

Tools > Database Browser 로 Data Browser를 띄운다

	File > New Report > Reports 다이알로그를 띄운다.
	---------------------------------------
	Physical 을 체크한 후,
	Name: 아무거나, 	Category : Table

	Options
		Table : Name, Comment 체크
			Column : Name, Comment, Is PK 체크
	---------------------------------------//
	한 후, OK
	우측의 데이터를 보면서, 컬럼을 드래그하여 위치를 바꾸거나
	우클릭해 Rename, Asc/Desc 등 적합하게 출력되게 맞춤

	All reports
	 >CA ERwin DM Reports > Table Reports >
	 에 추가된 리포트를 더블 클릭하여, 보고서 생성

Export from Data browser 팝업이 뜬다.
	Export : 	CSV 를 선택
	Export하여 적합한 위치에 저장하면 된다.
--------------------------------------------------------------------//


--------------------------------------------------------------------
레포트 파일(*.erp)이 있는 경우 - 엔티티 정보를 엑셀 파일로 저장하기

Tools > Database Browser 로 Data Browser를 띄운다 -

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

