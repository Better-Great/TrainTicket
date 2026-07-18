package config.entity;

import lombok.Data;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

/**
 * @author fdse
 */
@Data
@Entity
public class Config {
    /** Cap PK length for MySQL 8 utf8mb4 (255*4 exceeds 1000-byte index limit). */
    @Valid
    @Id
    @NotNull
    @Column(length = 64)
    private String name;

    @Valid
    @NotNull
    @Column(length = 255)
    private String value;

    @Valid
    @Column(length = 255)
    private String description;

    public Config() {
        this.name = "";
        this.value = "";
    }

    public Config(String name, String value, String description) {
        this.name = name;
        this.value = value;
        this.description = description;
    }

}
