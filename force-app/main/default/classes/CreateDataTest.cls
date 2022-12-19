@isTest
public class CreateDataTest {
	@isTest
    static void TestCreateData(){
        Test.setMock(HttpCalloutMock.class, new CreateDataMock());
        
        HttpResponse res = FinsCabinData.CreateData();
        System.assertEquals(200,res.getStatusCode());

    }
}