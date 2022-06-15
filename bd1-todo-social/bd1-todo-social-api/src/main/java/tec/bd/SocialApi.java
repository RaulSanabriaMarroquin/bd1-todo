package tec.bd;

import com.google.gson.Gson;

import java.util.Map;

import static spark.Spark.*;



public class SocialApi
{
    public static void main( String[] args )
    {

        Gson gson = new Gson();

        options("/", (request, response) -> {
            response.header("Content-Type", "application/json");
            return Map.of(
                    "message", "SOCIAL API V1");
        }, gson::toJson);
    }
}
