- GET `plates`
    - req: Cookie
    - rep:
        ```json
        [
            {
                "number": "plate number",
                "date": "ISO 8601 date",
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
