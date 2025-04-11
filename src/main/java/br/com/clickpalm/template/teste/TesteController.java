package br.com.clickpalm.template.teste;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/template")
public class TesteController {

    @GetMapping
    public ResponseEntity<String> testeTemplate() {
        return ResponseEntity.ok("TESTE REALIZADO COM SUCESSO CONTAINERS 2");
    }
}
