- GET `all`
    - req: Cookie
    - rep:
        ```json
        [
            {
                "number": "plate number",
                "dateTime": "ISO 8601 date time",
                "image": "Url to the image"
            }
        ]
        ```
- POST `login`
    - req:
        ```json
        {
            "username": "username",
            "password": "hashed password"
        }
        ```
    - rep: Cookie
