$hashVeeru = '$2a$10$cXPB7k1yDziBSl211IcvZuHE7vZYDZUgAbxIwfY7A2pBEAFavUrRK'
$hashAkhil = '$2a$10$MvgPI2Ih0Tf91mAeSpnJY.8zcwD.lLm31rdDyqZtW2DArChtPGiZm'
$hashRudra = '$2a$10$pDEJfaeVLfq7NkN3s.rjtOjDyJ1KCYy2rPH2li2gfj00Ji7OOwO.y'

# Let's see what passwords the user might have used:
$passwords = @('12345678', '123456789', '1234567890', 'admin123', 'admin1234', 'password123', 'Password123', 'password', 'Password', '11111111', '00000000', 'veeru800', 'akhil567', 'rudra245', 'veeru123', 'akhil123', 'rudra123', 'Sumanth@123', 'Sumanth123', 'sumanth47', 'Sumanth', 'sumanth', '123456', '12345', '1234', 'admin', 'veeru@800', 'akhil@567', 'rudra@245', 'veeru800@gmail.com', 'akhil567@gmail.com', 'rudra245@gmail.com')

# Let's test with a simple Java one-liner using BCrypt from the backend target classes
$cp = "backend/target/classes;backend/target/dependency/*"
$testScript = @"
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class TestBcrypt {
    public static void main(String[] args) {
        BCryptPasswordEncoder enc = new BCryptPasswordEncoder();
        String[] hashes = {
            "$hashVeeru",
            "$hashAkhil",
            "$hashRudra"
        };
        String[] names = {"veeru800", "akhil567", "rudra245"};
        String[] passes = {
            "12345678", "123456789", "1234567890", "admin123", "admin1234", "password123", "Password123",
            "password", "Password", "11111111", "00000000", "veeru800", "akhil567", "rudra245",
            "veeru123", "akhil123", "rudra123", "Sumanth@123", "Sumanth123", "sumanth47", "Sumanth",
            "sumanth", "123456", "12345", "1234", "admin", "veeru@800", "akhil@567", "rudra@245",
            "veeru800@gmail.com", "akhil567@gmail.com", "rudra245@gmail.com", "Admin@123", "Doctor@123",
            "Patient@123", "Doctor123", "Patient123", "AdminPassword123!", "DocPassword123!", "12345678a",
            "12345678A", "qwertyuiop", "asdfghjkl", "12341234", "11223344", "88888888", "99999999",
            "veeru@123", "akhil@123", "rudra@123", "veeru", "akhil", "rudra"
        };
        for (int i = 0; i < hashes.length; i++) {
            boolean found = false;
            for (String p : passes) {
                if (enc.matches(p, hashes[i])) {
                    System.out.println("FOUND MATCH for " + names[i] + ": " + p);
                    found = true;
                    break;
                }
            }
            if (!found) {
                System.out.println("No match yet for " + names[i]);
            }
        }
    }
}
"@
Set-Content -Path "backend/TestBcrypt.java" -Value $testScript
