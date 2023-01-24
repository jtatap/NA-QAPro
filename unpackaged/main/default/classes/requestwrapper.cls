global class requestwrapper{
    public String count{get; set;}
    public List<subscriber_class> Subscribers{get; set;}
    global class subscriber_class{
        public String BrandId{get; set;}
        public String balancepoints{get; set;}
        public String LoyaltyId {get; set;}
    }
    //public static requestwrapper parse(String json){
    //return (requestwrapper)System.JSON.deserialize(json,requestwrapper.class);
    //}
}