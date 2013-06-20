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

A classe **AKUser** permite que você também verifique se existe uma sessão valida, o método **isValidSession** retorna um **BOOL** (YES/NO) para informar a sessão valida.

###### importante lembrar que toda transação deve ter uma sessão valida para ser concretizada

```objetive-c
[user isValidSession]
```

#### Transação

Para efetuar a transação são necessários 2 passos

1 - Criar um objeto do tipo AKTransaction setando as propriedades necessarias para efetuar a transação

###### Todas as propriedades são necessarias exceto a imagem do produto

```objective-c
AKTransaction *transaction = [[AKTransaction alloc] init];
transaction.amount = 50.0f;
transaction.installment = 1;
transaction.productDescription = @"Compra teste SDK";
transaction.creditCardNumber = @"4012001038443335";
transaction.creditCardHolderName = @"AUTORIZAR";
transaction.creditValidates = @"06/15";
transaction.cvv = @"123";
transaction.name = @"Funalo de Tal";
transaction.cpf = @"370.761.736-03";
transaction.phone = @"11980807070";

NSString *signaturePath = [[NSBundle mainBundle] pathForResource:@"assinatura" ofType:@"jpg" inDirectory:nil];
transaction.signature = [NSData dataWithContentsOfFile:signaturePath];

NSString *productImagePath = [[NSBundle mainBundle] pathForResource:@"produto" ofType:@"jpg" inDirectory:nil];
transaction.productImage = [NSData dataWithContentsOfFile:productImagePath];
```

2 - A transação deve ser enviada atraves da classe **AKTransactionManager** utilizando o método **submitTransactionWithTransaction:(AKTransaction *)transaction success:(void (^)(id transactionInfo))success failure:(void (^)(NSDictionary *error))failure** que recebe como parametro o AKTransaction criado acima.

```objective-c
AKTransactionManager *manager = [[AKTransactionManager alloc] init];

[manager submitTransactionWithTransaction:transaction success:^(id transactionInfo) {
    NSLog(@"%@", transactionInfo);
} failure:^(NSDictionary *error) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Erro" message:[[error valueForKey:@"error"] componentsJoinedByString:@""] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}];
```

#### Parcelamento

Para saber o valor do parcelamento você deve utilizar o método, **calculeInstallmentValueWithAmount:(float)amount success:(void (^)(NSArray *installments))success failure:(void (^)(NSDictionary *error))failure**, que está em **AKTransaction**, esse método retorna o numero de parcelas o valor da parcela e o valor total, caso haja juros, a taxa juros pode ser encontrada na sua conta Akatus no site [https://site.akatus.com](https://site.akatus.com).

```objective-c

AKTransaction *transaction = [[AKTransaction alloc] init];
[transaction calculeInstallmentValueWithAmount:10.0f success:^(NSArray *installments) {
    NSLog(@"%@", installments);
} failure:^(NSDictionary *error) {
    NSLog(@"%@", error);
}];

```
Observação, o valor retornado no calculo da parcela é apenas para amostragem, o valor que deve ser enviado na transação é apenas o valor sem juros.
