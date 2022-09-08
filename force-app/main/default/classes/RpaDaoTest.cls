@isTest
private class RpaDaoTest {
    @isTest
    static void testNo1getDepartmentPicklist() {
        List<String> picklistValues = RpaDao.getDepartmentPicklist();
        System.assertEquals(6, picklistValues.size(), 'Get picklist size: ' + picklistValues.size());
    }

    @isTest
    static void testNo1getRpasByDept(){
        Test.startTest();
        List<RPA__c> listAcc =  new List<RPA__c>();
        Account accGet = new Account();
        accGet.Name = 'SF Test';
        accget.Rating = 'Warm';
        accGet.Department__c = '수주';
        insert accGet;
        for (Integer i = 0; i < 5; i++){
            RPA__c acc = new RPA__c();
            acc.TitleURL__c = 'Test News' + i;
            acc.URL__c= '#';
            acc.SummaryURL__c = 'Lorem ipsum dolor sit amet. Qui officia consequatur sed similique dicta et autem magnam ut voluptatem nihil et soluta possimus eos nemo provident.';
            acc.Customer_Card__c = accGet.Id;
            acc.CreatedDate__c = System.today();
            listAcc.add(acc);
        }
        System.debug('create acc list: ' + listAcc);
        insert listAcc;
        Test.stopTest();
        List<RPA__c> listRpas = RpaDao.getRpasByDept('수주');
        System.assertEquals(5, listRpas.size(), 'size: ' + listRpas.size());
    }

    @isTest
    static void testNo1getRpasByPageNumber(){
        Test.startTest();
        List<RPA__c> listAcc =  new List<RPA__c>();
        Account accGet = new Account();
        accGet.Name = 'SF Test';
        accget.Rating = 'Warm';
        accGet.Department__c = '수주';
        insert accGet;
        for (Integer i = 0; i < 5; i++){
            RPA__c acc = new RPA__c();
            acc.TitleURL__c = 'Test News' + i;
            acc.URL__c= '#';
            acc.SummaryURL__c = 'Lorem ipsum dolor sit amet. Qui officia consequatur sed similique dicta et autem magnam ut voluptatem nihil et soluta possimus eos nemo provident.';
            acc.Customer_Card__c = accGet.Id;
            acc.CreatedDate__c = System.today();
            listAcc.add(acc);
        }
        System.debug('create acc list: ' + listAcc);
        insert listAcc;
        Test.stopTest();
        RpaDao.NewsPaginationWrapper wrapper = RpaDao.getRpasByPageNumberAndDept(1, '수주');
        System.assertEquals(5, wrapper.listNews.size(), 'list size: ' + wrapper.listNews.size());
        System.assertEquals(1, wrapper.totalPages, 'total pages: ' + wrapper.totalPages);
        System.assertEquals(1, wrapper.currentPage, 'current: ' + wrapper.currentPage);
        System.assertEquals(1, wrapper.pagesArray.size(), 'page array: ' + wrapper.pagesArray.size());
    }
}
