return {
  name = "upstream-token-auth",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            token_url = {
              type = "string",
              required = true
            }
          },
          {
            parameters = {
              type = "string",
              required = true
            }
          },
          {
            tokentype = {
              type = "string",
              required = true
            }
          }, 
          {
            tokenexpiry = {
              type = "number",
              required = false
            }
          },                   
          {
            headers = {
              type = "string",
              required = false
            }
          },
          {
            responsetype = {
              type = "string",
              default = "json"
            }
          },
          {
            requesttype = {
              type = "string",
              default = "formparam"
            }
          }, 
          {
            tokenpath = {
              type = "string"
            }
          },          
        }
      }
    }
  }
}
