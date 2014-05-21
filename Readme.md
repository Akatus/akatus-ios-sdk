#AKCoreUser

O AKCoreUser é responsavel pelo login e dados do usuário

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

``` objective-c

AKUserCore *user = [AKUserCore shared];
[user logoutWithCompletion:^{
    <#code#>
}];

```

- Verificando sessão

``` objective-c

AKUserCore *user = [AKUserCore shared];
[user isValidSession];
```


