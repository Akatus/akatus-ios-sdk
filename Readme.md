- Login

``` objective-c

AKUserCore *user = [AKUserCore shared];

[self loginWithEmail:@"email" andPassword:@"password" success:^{
        <#code#>
    } failure:^(NSDictionary *error) {
        <#code#>
    }];

```

- Logout


