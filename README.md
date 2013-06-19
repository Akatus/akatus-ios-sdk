<p align="left" >
  <img src="https://site.akatus.com/wp-content/uploads/2012/12/logo.gif" alt="Akatus" title="Akatus">
</p>

## Objetivo


## Instalação

- Adicione o arquivo **Akatus.framework** dentro de sua aplicação
- No seu projeto em Build Setting adicione o framework Akatus em "Other Link Flags"

        -framework Akatus

### Dependencias

- CoreLocation

        <CoreLocation/CoreLocation.h>


## Como usar

Importe o framework Akatus dentro da sua classe
```objective-c
#import <Akatus/Akatus.h>
```

#### Login

Para fazer o login você deve utilizar a classe AKUser e utilizar o método **loginWithEmail:(NSString*)email andPassword:(NSString *)password** que retorna um bloco de sucesso ou falha, como vemos no exemplo:

```objective-c
AKUser *user = [Akuser sharedInstance];

[user loginWithEmail:self.email.text andPassword:self.password.text success:^{
    NSLog(@"Login efetuado com sucesso");
} failure:^(NSDictionary *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"erro" message:[error valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}];
```
