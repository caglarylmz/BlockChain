# Smart Contract'lara Giriş

## Basit bir Smart Contract Oluşturma

Bir değişkenin değerini belirleyen ve onu diğer sözleşmelerin erişmesi için ortaya çıkaran temel bir örnekle başlayalım.

```c++
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}
```

İlk satır, kaynak kodun GPL sürüm 3.0 altında lisanslandığını söyler. Kaynak kodu yayınlamanın varsayılan olduğu bir ortamda, makine tarafından okunabilen lisans belirteçleri önemlidir.

Solidty'de bir sözleşme, Ethereum blok zincirinde belirli bir adreste bulunan function(işlevler) ve data(state-durum)'lardır.

Burada oluşturulan contract; `uint storedData;` storredData adında ve uint tipinde state tutan bir değişken içerir. Bu değişken içeriğini görüntülemek için `get()` , değerini değiştirebilmek için ise `set` fonksiyonları içerir.

Yani bu contract veritabanında oluşturulmuş bir değer olarak düşünülebilir. Bu değer'e `get` ile ulaşır `set` ile içeriğini değiştirebiliriz.

c syntax dillerde state variable'lara `this` kullanarak erişebiliriz. Solidty'de bu kullanım tercih edilmemektedir.

Bu contract, şu an etherium ağındaki herkes tarafından erişilebilen ve tek bir numarayı saklayan bir yapıdadır. Herkes contract'ı kullanarak numarayı değiştirebilir. Bu durumun önüne geçmek için erişim kısıtlamaları kullanılır. Daha sonra bu konuyu ayrıntılı olarak inceleyeceğiz.

## Bir SubCurrency Örneği

```c++
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Coin {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    mapping (address => uint) public balances;

    // Events allow clients to react to specific
    // contract changes you declare
    event Sent(address from, address to, uint amount);

    // Constructor code is only run when the contract
    // is created
    constructor() {
        minter = msg.sender;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    // Errors allow you to provide information about
    // why an operation failed. They are returned
    // to the caller of the function.
    error InsufficientBalance(uint requested, uint available);

    // Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        if (amount > balances[msg.sender])
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}
```

Bu contract ile bazı yeni kavramlarla tanışıyoruz. Bunları inceleyelim.

`address public minter;` adress tipinde bir değişken oluşturur. `adress` aritmetik işlemlere izin vermeyen 160-bitlik bir değerdir. Sözleşmelerin adreslerini veya harici hesaplara ait bir SHA256 anahtar çiftinin public anahtarının bir karmasını depolamak için uygundur.

`public` anahtar sözcüğü, durum değişkeninin geçerli değerine, sözleşmenin dışından erişmeyi sağlar. Bu keyword olmadan, diğer sözleşmelerin bu değişkene erişme yolu yoktur. Bu anahtar kelimenin eşdeğeri aşağıdaki sözdizimidir.

`function minter() external view returns (address) { return minter; }`

Yani public olarak belirtmediğimiz bir değişkeni bu fonksiyon ile erişebilir hale getirebiliriz.

`mapping (address => uint) public balances;` daha karmaşık bir değişken tanımlıyoruz. Bu değişken de `minter`  gibi public, yani dışarıdan erişime izin verilen yapıdadır. Ancak bu bir map tipinde değişkendir. adress'leri uint'e eşleyen bir yapıdır. Bu sayede her adress'e karşılık bir bakiye değeri atayabiliriz. Bakiye - olamayacağı için uint tipinde bir değişken tercih ediyoruz.
