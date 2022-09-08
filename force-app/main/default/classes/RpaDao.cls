/**
 * class Dao of RPA__c
 *
 * @author nam.nguyen4
 */
public with sharing class RpaDao {
    
    static final Integer PAGE_SIZE = 5;

    /**
     * get Department picklist's values
     * 
     * @return List<String> values
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getDepartmentPicklist(){
        try {
            List<String> picklistValue = new List<String>();
            Schema.DescribeFieldResult objFieldDescribe = Account.Department__c.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                picklistValue.add(objPickList.getValue());
            }
            return picklistValue;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }

    /**
     * get List 5 recently records of RPA within 2 weeks from now
     * @param deptName department value
     * @return List<RPA__c> list records
     */
    @AuraEnabled(cacheable=true)
    public static List<RPA__c> getRpasByDept(String deptName){
        try {
            Date lastTwoWeek = System.Today() - 14;  
            List<RPA__c> listRpa = [SELECT Name, TitleURL__c, SummaryURL__c, ImageURL__c, 
                                    Customer_Card__c, CreatedDate__c, Customer_Card__r.Department__c 
                                    FROM RPA__c 
                                    WHERE CreatedDate__c >= :lastTwoWeek 
                                    AND Customer_Card__r.Department__c LIKE :deptName
                                    ORDER BY CreatedDate__c DESC, Name DESC LIMIT :PAGE_SIZE];
            return listRpa;
        }
        catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }

    /**
     * get List records of RPA and pagination data
     * @param deptName department value
     * @param pageNumber chosen page number
     * @return pagination data
     */
    @AuraEnabled(cacheable=true)
    public static NewsPaginationWrapper getRpasByPageNumberAndDept(Integer pageNumber, String deptName){
        try {
            NewsPaginationWrapper wrapper = new NewsPaginationWrapper();
            System.debug('dept param: ' + deptName);
            List<Integer> pages = new List<Integer>();
            Integer offset = ((pageNumber - 1) * PAGE_SIZE);
            String queryCount = 'SElECT COUNT() FROM RPA__c WHERE Customer_Card__r.Department__c LIKE :deptName';
            String query = 'SELECT Id, Name, TitleURL__c, SummaryURL__c, ImageURL__c, CreatedDate__c,  Customer_Card__r.Department__c ' + 
                            'FROM RPA__c WHERE Customer_Card__r.Department__c LIKE :deptName ' +
                            'ORDER BY CreatedDate__c DESC, Name DESC LIMIT 5 OFFSET :offset';
            System.debug('query: ' + query);
            List<RPA__c> listRpa = Database.query(query);
            Integer totalRecords = Database.countQuery(queryCount);
            wrapper.listNews = listRpa;
            wrapper.currentPage = pageNumber;
            wrapper.totalPages = (Math.ceil(totalRecords / PAGE_SIZE)).intValue();
            for (Integer i = 1; i <= wrapper.totalPages; i++) {
                pages.add(i);
            }
            wrapper.pagesArray = pages;
            return wrapper;
        }
         catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }

    public class NewsPaginationWrapper {
        @AuraEnabled public List<RPA__c> listNews;
        @AuraEnabled public Integer totalPages;
        @AuraEnabled public Integer currentPage;
        @AuraEnabled public List<Integer> pagesArray;
    }
}
