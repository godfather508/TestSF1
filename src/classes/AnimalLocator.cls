public class AnimalLocator {
    public class JSON2Apex {
        public Animal animal;        
    }
    
    public class Animal {
        public Integer id;
        public String name;
        public String eats;
        public String says;
    }
    
    public static String getAnimalNameById(Integer i) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = 'https://th-apex-http-callout.herokuapp.com/animals/' + i;
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        String name = '';
        if (response.getStatusCode() == 200) {
            JSON2Apex animal = (JSON2Apex) System.JSON.deserialize(response.getBody(), JSON2Apex.class);
            name = animal.animal.name;
        }
        return name;
    }
}