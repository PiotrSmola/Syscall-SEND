# Projekt: Wywołanie systemowe SEND

## Wprowadzenie

Celem tego projektu jest zilustrowanie działania wywołania systemowego `send`, które jest kluczowe w komunikacji sieciowej. Umożliwia ono serwerowi przesyłanie danych do klienta za pomocą gniazd sieciowych, upraszczając operacje związane z transmisją i zarządzaniem buforami. Projekt wykorzystuje implementacje w języku C oraz w asemblerze, które pokazują różnice między używaniem wysokopoziomowego API a bezpośrednim wywoływaniem systemowym.

## Działanie wywołania systemowego SEND

Wywołanie systemowe `send` realizuje przesyłanie danych między serwerem a klientem w kontekście otwartego połączenia sieciowego.

### Parametry:
- **sockfd** (deskryptor gniazda): Deskryptor połączenia z klientem.
- **buf** (bufor danych): Wskaźnik na dane do przesłania.
- **len** (długość danych): Liczba bajtów do przesłania.
- **flags**: Flagi transmisji (domyślnie `0`).

### Zwracana wartość:
Liczba bajtów wysłanych lub `-1` w przypadku błędu.

## Kroki w realizacji serwera TCP:

1. **Tworzenie gniazda**: 
   Wywołanie `socket` tworzy gniazdo sieciowe TCP w domenie IPv4.
2. **Ustawienie opcji gniazda**: 
   `setsockopt` umożliwia ponowne użycie adresu i portu (SO_REUSEADDR).
3. **Przypisanie adresu**: 
   Wywołanie `bind` przypisuje lokalny adres IP (`127.0.0.1`) i port (`8081`) do gniazda.
4. **Nasłuchiwanie na połączenia**: 
   `listen` ustawia gniazdo w tryb nasłuchu, umożliwiając odbieranie połączeń.
5. **Akceptowanie połączenia**: 
   `accept` oczekuje na połączenie od klienta i zwraca deskryptor tego połączenia.
6. **Wysyłanie danych**: 
   `send` przesyła dane do klienta przez otwarte połączenie.
7. **Zamykanie połączeń**: 
   `close` zamyka deskryptory gniazd i zwalnia zasoby.

## Kompilacja i uruchamianie

### Kod w asemblerze
1. Plik `send.asm`.
   Skompiluj i uruchom kod:
   ```bash
   nasm -f elf64 send.asm -o send.o
   ld send.o -o send
   ./send &
   nc 127.0.0.1 8081

### Kod w języku C
1. Plik `send.c`.
   Skompiluj i uruchom kod:
   ```c
   gcc send.c -o send
   ./send &
   nc 127.0.0.1 8081

## Podsumowanie

Powyższe programy, napisane w języku C oraz w asemblerze, ilustrują działanie wywołania systemowego `send` w kontekście serwera TCP. 

- **Kod w C**: Korzysta z wysokopoziomowych funkcji, takich jak `socket`, `bind`, `listen`, `accept`, i `send`. Podejście to upraszcza implementację dzięki standardowym bibliotekom i jest bardziej przyjazne dla programistów.
  
- **Kod w asemblerze**: Demonstruje bezpośrednie użycie wywołań systemowych (`syscall`) do zarządzania gniazdami sieciowymi. To podejście oferuje większą kontrolę nad procesem, ale wymaga bardziej szczegółowej wiedzy o architekturze systemu.

**Wywołanie systemowe `send`** umożliwia przesyłanie danych z serwera do klienta przez aktywne połączenie. Implementacja w obu językach pokazuje różnice w abstrakcji i poziomie szczegółowości w projektowaniu aplikacji sieciowych. Dzięki temu projekt pozwala lepiej zrozumieć mechanizmy zarządzania komunikacją sieciową.
