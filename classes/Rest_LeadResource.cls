@RestResource(urlMapping='/Lead/*')
global with sharing class Rest_LeadResource {

    @HttpGet
    global static List<Lead> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('req: ' + req);
        System.debug('req.headers: ' + req.headers);
        
        //Get headers
        String filterFirstName = Rest_LeadResource.cleanHeader(req.headers.get('filterFirstName'));
        String filterLastName = Rest_LeadResource.cleanHeader(req.headers.get('filterLastName'));
        String filterCompany = Rest_LeadResource.cleanHeader(req.headers.get('filterCompany'));
        String filterCity = Rest_LeadResource.cleanHeader(req.headers.get('filterCity'));
        String filterState = Rest_LeadResource.cleanHeader(req.headers.get('filterState'));
        String filterToday = Rest_LeadResource.cleanHeader(req.headers.get('filterToday'));
        
        System.debug('filterFirstName: ' + filterFirstName);
        System.debug('filterToday: ' + filterToday);
        List<String> predicateList = new List<String>();
        if (filterFirstName != '')
            predicateList.add('FirstName LIKE \'%' + filterFirstName.trim() + '%\'');
        if (filterLastName != '')
            predicateList.add('LastName LIKE \'%' + filterLastName.trim() + '%\'');
        if (filterCompany != '')
            predicateList.add('Company LIKE \'%' + filterCompany.trim() + '%\'');
        if (filterCity != '')
            predicateList.add('City LIKE \'%' + filterCity.trim() + '%\'');
        if (filterState != '')
            predicateList.add('State LIKE \'%' + filterState.trim() + '%\'');
        if (filterToday != '' && filterToday.toLowerCase() != 'false')
            predicateList.add('CreatedDate = TODAY');
        
        String queryPredicate = 'WHERE ';
        for (String pred : predicateList) {
            queryPredicate += pred + ' AND ';
        }
        System.debug('queryPredicate: ' + queryPredicate);
        if (queryPredicate.length() == 6)
            queryPredicate = queryPredicate.substring(0, queryPredicate.length() - 6);//unwind WHERE 
        else if (queryPredicate.length() > 4)
            queryPredicate = queryPredicate.substring(0, queryPredicate.length() - 4);//unwind AND
        System.debug('queryPredicate: ' + queryPredicate);
        String queryString = 'SELECT FirstName, LastName, Company, City, State'
                + ' FROM Lead ' + queryPredicate;
        System.debug('queryString: ' + queryString);
        List<Lead> result = Database.query(queryString);

        System.debug('get req: ' + req);
        System.debug('requestBody: ' + String.valueOf(req.requestBody));
        System.debug('get res: ' + res);
        System.debug('result: ' + result);
        return result;
    }
    
    @HttpPost
    global static List<Lead> doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('received req: ' + req);
        System.debug('requestBody: ' + String.valueOf(req.requestBody));
        System.debug('requestBody: ' + req.requestBody.toString());
        List<Lead> reqLeads = (List<Lead>)JSON.deserialize(req.requestBody.toString(), List<Lead>.class);
        System.debug('reqLeads: ' + reqLeads);
        Database.upsert(reqLeads);
        System.debug('received res: ' + res);
        //System.debug('received stringParam: ' + stringParam);
        return reqLeads;
    }
    
    @HttpDelete
    global static List<Lead> doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('received req: ' + req);
        System.debug('requestBody: ' + String.valueOf(req.requestBody));
        System.debug('requestBody: ' + req.requestBody.toString());
        List<Lead> reqLeads = (List<Lead>)JSON.deserialize(req.requestBody.toString(), List<Lead>.class);
        System.debug('reqLeads: ' + reqLeads);
        System.debug('received res: ' + res);
        //System.debug('received stringParam: ' + stringParam);
        Database.delete(reqLeads);
        //return deletedLeadIdList;
        return reqLeads;
    }
    
    global static String cleanHeader(String header) {
        String noQuoteHeader = String.escapeSingleQuotes(header);
        System.debug('noQuoteHeader: ' + noQuoteHeader);
        String deserHeader = (String)JSON.deserialize(noQuoteHeader, String.class);
        System.debug('Json.deserialize header: ' + deserHeader);
        return deserHeader;
    }

}