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

`mapping (address => uint) public balances;` daha karmaşık bir değişken tanımlıyoruz. Bu değişken de `minter`  gibi public, yani dışarıdan erişime izin verilen yapıdadır. Ancak bu bir map tipinde değişkendir. adress'leri uint'e eşleyen bir yapıdır. Bu sayede her adress'e karşılık bir bakiye değeri atayabiliriz. Bakiye - değer alamayacağı için uint tipinde bir değişken tercih ediyoruz.

Bu satırın eşleniği aşağıdaki ifadedir:

```c++
function balances(address _account) external view returns (uint) {
    return balances[_account];
}
```

`event Sent(address from, address to, uint amount);` Bu satırda bir event oluşturuyoruz. Event, emit edildiği anda çalışan ve bir olay bildiren yapılardır. Etherium istemcileri ve web3.js ile web uygulamarı bu olayları dinleyebilir. Event emit edildiği an, dinleyicilerin belirtilen argumanları (from,to ve amount) izlenmesini mümkün kılan değişkenler oluşur.

Burada event send() fonksiyonunun sonunda emit edilmiştir. Bir dinleyici bu emit'i alarak aktarılan verileri görebilir.

Aşağıda verilen javascript kodunu kullanarak bu event'i dinleyebilir ve kullanıcıya veriyi görüntüleyecek bir arayüz oluşturabilirsiniz.

```c++
Coin.Sent().watch({}, '',function(error, result) {
if (!error) {
        console.log("Coin transfer: " + result.args.amount +
            " coins were sent from " + result.args.from +
            " to " + result.args.to + ".");
        console.log("Balances now:\n" +
            "Sender: " + Coin.balances.call(result.args.from) +
            "Receiver: " + Coin.balances.call(result.args.to));
    }
})
```

`constructor()` Contract'ın oluşturulduğu anda çağrılan özel bir fonksiyondur.  
`minter = msg.sender;` ile Contract'ı oluşturan kişinin adresini kalıcı olarak saklar. msg değişkeni blockzincir'de global olarak tanımlı ve erişime izin veren özellikler içeren bir değişkendir.
`msg.sender`  her zaman geçerli(external) fonksiyonun çağrısının geldiği adrestir.

Contract'ı oluşturan, kullanıcıların ve diğer harici contract'ları erişebileceği fonksiyonlar `mint()` ve `send()` 'dir.

`mint()` fonksiyonu yeni oluşturulan bir miktar parayı başka bir adrese göndermeye yarar.

 `require(msg.sender == minter);` ile sadece sözleşmeyi oluşturanın mint edebilmesi sağlanmaktadır. Eğer mint fonkisyonunu çağıran, sözleşmeyi oluşturan değilse( bunu constructur'da `minter = msg.sender` ile tanımlamıştık) fonksiyon bu noktada kesilir ve tüm işlemleri iptal eder.

Genel olarak, contract'ı oluşturan istediği kadar token basabilir. Ancak bir noktada oveflow hatası oluşacaktır. Çünkü basılabilecek token `uint` (`2**256 - 1`) kadar değer ile sınırlıdır. (`mapping (address => uint) public balances`). Bu değerin aşılacağı durumda hata oluşur

Errors bir işlemin neden başarısız olduğu hakkında bilgi verir. `revert` ile birlikte kullanılır. `revert`, `require` ile benzer şekilde tüm değişiklikleri koşulsuz iptal eder. Ek olarak oluşan hata bilgilerini döner.

`send` fonksiyonu herhangi biri tarafından(bu token'a zaten sahip olan biri) başka birine token göndermek için kullanılır.

Göndericinin elinde göndermek istediği kadar tokeni yoksa if koşulu çalışır ve revert ile yeterli para olmadığını belirten InsufficentBalance hatası gönderilir. Tüm işlemler iptal edilir.

Bir adrese token göndermek için bu sözleşmeyi kullanırsanız, o adrese bir blok zinciri gezgininde baktığınızda hiçbir şey görmezsiniz, çünkü gönderdiğiniz kayıt ve bakiyeler yalnızca o token'ın veri deposunda saklanır. Events kullanarak, yeni tokeninizin işlemlerini ve bakiyelerini takip eden bir "blockchain explorer" oluşturabilirsiniz, ancak token sahiplerinin adreslerini değil, token sözleşme adresini incelemelisiniz.

## Blockchain Temelleri

### Transactions - İşlemler

Blockchain global olarak paylaşılan işlemsel bir veritabanıdır. Herkes ağa katılarak verileri okuyabilir. Veritabanındaki bir şeyi değiştirmek için diğer herkes tarafından kabul edilen bir transaction oluşturulmalıdır. Transaction yapılmak istenen değişikliğin blokcchain üzerinde tamamen uygulandığı ya da tamamen başarısız olduğu anlamına gelir. Transaction uygulanırken diğer hiç bir transaction onu değiştiremez.

Örnek olarak, elektronik para birimindeki tüm hesapların bakiyelerini listeleyen bir tablo hayal edin. Bir hesaptan diğerine transfer talep edilirse,  tutar bir hesaptan çıkarıldığında her zaman diğer hesaba eklenmesi sağlanır. Herhangi bir nedenle tutarın hedef hesaba eklenmesi mümkün değilse hiç bir değişiklik yapılmaz.

Ayrıca, bir transaction her zaman sender (creator) tarafından kriptografik olarak imzalanır. Bu, veritabanındaki belirli değişikliklere erişimi korumayı sağlar. Elektronik para örneğinde, basit bir çek, yalnızca hesabın anahtarlarını elinde tutan kişinin ondan para transfer edebilmesini sağlar.

### Blocks

Üstesinden gelinmesi gereken en büyük engellerden biri (Bitcoin terimleriyle) “çifte harcama saldırısı-double-spend attack” olarak adlandırılan fenomendir: Ağda aynı anda bir hesaptan para çekmek isteyen iki işlem varsa ne olur? İşlemlerden yalnızca biri, -genellikle ilki- geçerli olabilir. Sorun şu ki, “ilk” peer-to-peer network'de geçerli bir terim değildir.

Bunun soyut cevabı, umursamanıza gerek olmadığıdır. Anlaşmazlığı çözerek, sizin için global olarak kabul edilen bir işlem sırası seçilecektir. İşlemler "blok" adı verilen bir pakette toplanacak ve daha sonra yürütülecek ve katılan tüm düğümler arasında dağıtılacaktır. İki işlem birbiriyle çelişirse, ikinci olan reddedilir ve bloğun parçası olmaz.

Bu bloklar zaman içinde lineer bir dizi oluşturur ve “blockchain” kelimesi buradan gelir. Bloklar zincire oldukça düzenli aralıklarla eklenir - Ethereum için bu kabaca her 17 saniyede birdir-.

Order selection mechanism (“madencilik” olarak adlandırılır) bir parçası olarak, blokların zaman zaman  -yalnızca zincirin ucunda ise- geri alınması olasıdır. Belirli bir bloğun üstüne ne kadar çok blok eklenirse, bu bloğun geri alınması o kadar zorlaşır. Yani işlemleriniz geri alınabilir ve hatta blok zincirinden kaldırılabilir.

İşlemlerin bir sonraki bloğa veya herhangi bir belirli gelecek bloğa dahil edilmesi garanti edilmez, çünkü bloğa dahil edlime işlemi göndericiye değil, madencilere bağlıdır.

## The Ethereum Virtual Machine - EVM

### Genel Bakış

Ethereum Sanal Makinesi veya EVM, Ethereum'daki akıllı sözleşmeler için çalışma zamanı ortamıdır. Yalnızca korumalı değil aynı zamanda tamamen yalıtılmıştır bir alandır. Bu da EVM içinde çalışan kodun ağ, dosya sistemi veya diğer işlemlere erişimi olmadığı anlamına gelir. Akıllı sözleşmeler, diğer akıllı sözleşmelere bile sınırlı bir erişime sahiptir.

### Accounts - Hesaplar

Ethereum'da aynı adres alanını paylaşan iki tür account vardır: Public-Private key çiftleri (yani insanlar) tarafından kontrol edilen **External Accounts**. Account ile birlikte depolanan ve kod tarafından kontrol edilen **Contract Accounts**.

**External Account**un adresi public key ile belirlenirken, bir **Contract Account**un adresi contract oluştuğu anda belirlenir. (Creator adresinden ve bu adresten gönderilen transaction sayısından türetilir).

Hesabın kodu depolayıp saklamadığına bakılmaksızın, iki account türü de EVM tarafından eşit olarak ele alınır.

Her account'un, **storage** adı verilen 256-bit sözcükleri 256-bit sözcüklere eşleyen -hashmap- kalıcı bir anahtar-değer deposu vardır.  

Ayrıca, her hesabın Ether olarak bir **balance**ı -bakiye- vardır. (tam olarak “Wei” cinsinde 1 Ether 10**18 wei'dir) ve bu balance Ether içeren transactions'lar ile değiştirilebilir.

### Transactions

Transasction, bir account'tan diğerine gönderilen bir mesajdır. Transactions'lar binary data("payload" olarak adlandırılır) ve Ether içerebilir.

Bir contract oluşturulurken kodu hala boştur. Bu nedenle, constructor yürütmeyi bitirene kadar yapım aşamasındaki sözleşmeyi çağırmamalısınız.

### Gas

Oluşturulduktan sonra, her transaction, işlemi gerçekleştirmek için gereken iş miktarını sınırlamak ve aynı zamanda bu işlem için ödeme yapmak olan belirli bir miktarda gas ile ücretlendirilir. EVM işlemi gerçekleştirirken, gas belirli kurallara göre kademeli olarak tüketilir.

Gas fiyatı, gönderen hesaptan **gas_price * gas**'ı peşin olarak karşılanan, transaction'u oluşturan kişi tarafından belirlenen bir değerdir. İşlem gerçekleştikten sonra kalan gas miktarı iade edilir.

Gas herhangi bir noktada tükenirse, mevcut çağrı çerçevesindeki duruma yapılan tüm değişiklikleri geri alan bir out-of-gas exception tetiklenir.

### Storage, Memory ve Stack

EVM, veriyi depolayabileceği 3 alana sahiptir. Bunlar storage,memory ve stack'tir.

Her account, **storage** olarak adlandırılan kalıcı bir veri alanına sahiptir. Storage, 256 bit sözcükleri 256 bit sözcüklerle eşleyen bir anahtar/değer deposudur(HashMap). Bir contract'dan storage'i numaralandırmak mümkün değildir. 
Storage'i okumak, bir storage'de veri oluşturmaktan veya veri güncellemekten daha maliyetlidir. Bu nedenle contract'da storage okuma işlemleri en aza indirilmelidir. Bunun için ön belleğe alma, matematiksel işlemler gibi veri işlemleri storage'de yapılmamalıdır.

Bir contract'ın sadece kendi storage'ine erişimi vardır. Başka bir contract'ın strorage'ine okuma veya yazma yapamaz.

**memory**, bir contract'ın her mesaj çağrısı için yeni bir örneğinin(instance) oluşturulduğu bellek alanıdır. Memory doğrusal ve byte düzeyinde adreslenebilirdir. Memory üzerine yazmalar 8bit veya 256 bit olabilirken, okumalar 256 bit ile sınırlıdır. Daha önce erişilmemiş bir memory adresine erişirken ( okuma veya yazma) memory bir 256 bit alan ile genişletilir. Genişleme anında gas bedeli ödenmelidir. Bellek kullanımı quadratic olarak artan bir gas maliyetine sahiptir.

EVM bir kayıt makinesi değil, bir yığın(stack) makinesidir. Bu nedenle tüm hesaplamalar **stack** adı verilen veri alanında gerçekleşir. Max 1024 eleman boyutuna sahiptir ve her eleman 256 bit lik data içerebilir.

Stack'e erişim üst uçla sınırlıdır. En üstteki 16 öğeden birini stack'in üstüne kopyalamak veya en üstteki öğeyi altındaki 16 öğeden biriyle değiştirmek mümkündür. 
Bir işlem gerçekleştiğinde en üstteki eleman alınır ve sonuncu yığına koyulur. Stack öğeleri, daha derin erişim için storage veya memory alanlarına taşınabilir. Ancak stack'in en üst elemanları çıkarılmadan daha alt elemanlara eişim mümkün değildir.

### Talimat Seti - Instruction Set

Konsensüs sorunlarına neden olabilecek yanlış veya tutarsız uygulamalardan kaçınmak için EVM'nin komut seti minimum düzeyde tutulur. Tüm komutlar, temel veri türü, 256 bitlik word veya bellek dilimleri (veya diğer bayt dizileri) üzerinde çalışır. Her zamanki aritmetik, bit, mantıksal ve karşılaştırma işlemleri mevcuttur. Koşullu ve koşulsuz atlamalar mümkündür. Ayrıca sözleşmeler, mevcut bloğun numarası ve zaman damgası gibi ilgili özelliklerine erişebilir.

### Mesaj Çağrıları - Message Calls

Bir Contract, diğer contract'ları çağırabilir veya message call yoluyla non-contract account'lara Ether gönderebilir. Message Calls, bir kaynağa-source-, bir hedefe-target-, veri yüküne-payload-, Ether, gas ve dönüş verilerine sahip olmaları bakımından transaction'lara benzer. Aslında, her transaction, sırayla başka message call yaratabilen üst düzey bir message call'dır.

Bir contract kalan gas miktarının ne kadarının iç mesaj çağrısı ile gönderilmesi ve ne kadarının elinde kalması gerektiğine karar verebilir. Bir out-of-gas hatası oluştuğunda - veya herhangi bir başka hatada- stack'te inner message call ile bir hata değeri bildirilir. Bu durumda sadece mesaj çağrısı ile birlikte gönderilen gas kullanılır. Solidity de çağırılan contract bu gibi durumlarda varsayılan olarak manuel bir istisnaya neden olur, so that exceptions “bubble up” the call stack.

Daha önce de belirtildiği gibi, aranan contaract(arayan ile aynı olabilir) yeni temiz bir memory-bellek-  instance-örneği- alacak ve çağrı yüküne-call period-  erişime sahip olacaktır. Bu **calldata** adı verilen ayrı bir alandan sağlanacaktır. Yürütme işlemi  bittikten sonra, arayan tarafından önceden tahsis edilen arayanın hafızasındaki bir yerde saklanacak olan verileri döndürebilir. Tüm bu aramalar tamamen senkronizedir.

Çağrılar 1024'lük bir derinlikle sınırlıdır, bu da daha karmaşık işlemler için özyinelemeli çağrılar yerine döngülerin tercih edilmesi gerektiği anlamına gelir. Ayrıca, bir mesaj aramasında yalnızca 63/64 gas iletilebilir. Bu da uygulamada 1000'den biraz daha az bir derinlik sınırına neden olur.

### Delegatecall / Callcode and Libraries

**Delegate Call**; message call'ın özel bir çeşididir. **Delegate Call** hedef adreste yürütülen kodun message call context'inde yürütülür. msg.sender ve msg.value değerlerini değiştirmez.

Bu bir contract'ın çalışma zamanında farklı bir adresten dinamik olarak kod yükleyebileceği anlamına gelir. Storage, güncel adres ve bakiye-balance- hala call yapan contract'a aittir ve yalnızca call yapan adresten kod alınır.

Bu, Solidity'de  **library** özelliğinin uygulanmasını mümkün kılar.

### Logs
