# Relatório do Processo — Prova do Primeiro Bimestre

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Disciplina:** DevOps — 2026.2  
**Ferramenta de IA utilizada:** Kiro (Spec-Driven Development)

---

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

Nesta jornada da prova realizei a sequência da seguinte forma: primeiro ponto crucial para um projeto é o GIT/GITHUB, para ter o versionamento e conseguir recuperar caso algo aconteça errado e conseguir subir para o site e conseguir ver o progresso do projeto. Logo após isso segui com o Docker para começar a construção do ambiente e com o container isolado antes de orquestar o mesmo (AULA 01).

Após isso segui com o Docker Compose para construir de forma local e rodar API + Banco (AULA 02).

Agora que fizemos todo o ambiente de forma local fomos à construção das VPC, EC2, usamos a AWS para trabalharmos juntamente com o Academy para termos testes reais (AULA 03/04).

Em seguida entrou o RDS — depois de ter criado a VPC com as subnets era o momento de criar o banco gerenciado (AULA 05).

O remote state fez parte do projeto a partir deste momento, antes dos módulos principais, porque o backend precisa existir antes do `terraform init` (AULA 06). Feito isso, iniciamos os módulos para a VPC e alimentando o input de um módulo para outro — EC2/RDS (AULA 06).

A IA esteve presente lado a lado neste projeto, mas não como dominante, e cada processo foi validado por mim antes de ser aplicado.

---

## Questão 2 — O Processo com IA como Copiloto

Utilizei o **Kiro** como copiloto neste projeto usando o fluxo Spec-Driven Development. A ferramenta me gerou os módulos do Terraform, Dockerfile, Docker Compose e API, sendo que cada processo precisava da minha aprovação para executar. Sendo assertivo nesta parte do projeto, isso economizou horas de trabalho e escrita de código.

### Prompts principais utilizados

A conversa com o Kiro foi conduzida dentro do próprio IDE, com mensagens direcionadas. Os prompts mais relevantes foram:

**Prompt 1 — Definindo o papel da IA:**
> "Kiro, seja especialista em DEVOPS e AWS, e se integre da prova-primeiro-bimestre.md e o que já foi realizado"

Esse prompt foi fundamental porque definiu o escopo da IA logo no início. Ao pedir que ela fosse especialista em DevOps e AWS e lesse o enunciado da prova, o Kiro conseguiu entender o contexto completo — Learner Lab, restrições de IAM, módulos Terraform, CRUD com PostgreSQL — e trabalhar dentro dessas restrições sem que eu precisasse repetir o contexto em cada mensagem.

**Prompt 2 — Solicitando evidências textuais:**
> "O professor pede prints como evidência, vamos realizar essa parte também"

O Kiro gerou os arquivos `.txt` de evidência (`api-local-test.txt`, `git-log.txt`, `compose-ps.txt`) executando os comandos reais contra os containers locais e capturando os outputs. Também atualizou o `entrega.md` com todos os blocos de evidência formatados.

**Prompt 3 — Roteiro de prints:**
> "Os prints eu mesmo faço a captura, me sinalize dos pontos para eu realizar"

O Kiro criou um roteiro numerado com 12 prints, o comando exato a rodar antes de cada captura e o que cada print deveria mostrar — desde o `git log` até o `terraform destroy`. Isso organizou o processo de documentação de forma eficiente.

**Prompt 4 — Erro de token expirado:**
> "matheus-mantovani@Manto-Linux:~/...$ terraform destroy -auto-approve — Error: validating provider credentials: ExpiredToken"

Aqui a IA diagnosticou o problema imediatamente: token AWS expirado no Learner Lab. Orientou a renovar as credenciais via AWS Details → AWS CLI e colar no `~/.aws/credentials`. Quando o problema evoluiu para bucket S3 pertencente a outra conta (Lab expirado), o Kiro identificou que o nome do bucket é global na AWS, criou um novo bucket com nome baseado no Account ID atual (`tfstate-reservas-180239260670`) e atualizou o `providers.tf` automaticamente.

### O que a IA gerou bem

- Estrutura completa dos módulos Terraform (`vpc`, `security-group`, `ec2`, `rds`) com composição entre eles
- `user_data.sh` para a EC2 (instalação do Docker, pull da imagem, execução com variáveis de ambiente do RDS)
- CRUD completo da API Node.js/Express com PostgreSQL
- `Dockerfile` multi-stage com usuário não-root
- `docker-compose.yml` com healthcheck, rede customizada e `depends_on` com condição
- Diagnóstico e resolução de erros de infraestrutura em tempo real

### O que precisou de ajuste manual

- Restrições do Learner Lab não eram conhecidas pela IA inicialmente — precisei informar que não é possível criar IAM users/roles e que deve usar `LabRole`/`LabInstanceProfile`
- Ajuste de credenciais temporárias (`aws_session_token`) que o Kiro não consegue acessar diretamente
- Validação visual de cada `terraform plan` antes do `apply` — responsabilidade minha, não da IA

### Comparação: com IA vs. sem IA

Sem a IA, estimo que a parte de Terraform (4 módulos + composição + remote state) levaria entre 4 e 6 horas só de escrita e debugging. Com o Kiro, foi aproximadamente 1 hora incluindo os ajustes. O maior ganho foi na estrutura dos módulos e no `user_data.sh` — partes que exigem bastante atenção a detalhes e são propensas a erros difíceis de diagnosticar.

---

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

A arquitetura está organizada da seguinte forma: a EC2 fica na subnet pública porque precisa de IP público para receber requisições externas na porta 3000. Já o RDS fica na subnet privada porque o banco de dados nunca deve estar exposto à internet — o atributo `publicly_accessible = false` garante isso no Terraform.

O único caminho até o banco é pela porta 5432, exclusivamente a partir do Security Group da EC2. Isso implementa o princípio do menor privilégio: nem SSH, nem acesso externo, apenas a aplicação que precisa do banco.

O Learner Lab não permite criar IAM users/groups/roles. A `LabRole` já existe com as permissões necessárias, e o `LabInstanceProfile` é associado à EC2 para que ela acesse serviços da AWS sem credenciais hardcoded. As credenciais temporárias de cada sessão (`aws_access_key_id`, `aws_secret_access_key`, `aws_session_token`) são configuradas via `~/.aws/credentials` e expiram com o Lab — o que obriga a renovação a cada sessão, um comportamento mais seguro do que credenciais permanentes.

Um ajuste importante que o Lab exigiu foi o nome do bucket de remote state: como o Lab criou uma conta AWS nova ao expirar, o bucket da sessão anterior ficou inacessível (pertencia a outra conta). A solução foi criar um bucket com nome baseado no Account ID atual para garantir unicidade global.

---

## Questão 4 — Validação e Responsabilidade

Apliquei um checklist por tópicos pedindo ao Kiro que me devolvesse os itens para trabalharmos do 1 ao 7. Optei por essa estratégia para ter espaços de trabalho definidos e mais facilidade na hora de corrigir erros em etapas isoladas.

Uma prática que adotei para melhorar o filtro da IA foi definir o papel dela logo no primeiro prompt: "seja especialista em DevOps e AWS". Isso funcionou como contexto persistente, evitando que a IA gerasse soluções genéricas sem considerar as restrições do Learner Lab.

O processo de validação antes de cada `terraform apply` seguiu esta sequência:
1. `terraform validate` — zero erros de sintaxe
2. `terraform plan` — leitura dos 14 recursos planejados, confirmação de que nada seria destruído por engano
3. Revisão manual do plan: verificar `publicly_accessible = false`, `storage_encrypted = true`, `iam_instance_profile = "LabInstanceProfile"`, regras de SG
4. Verificar que `.env`, `*.tfstate`, `.terraform/` estavam no `.gitignore` antes de qualquer push

Se eu tivesse aceitado o código da IA sem revisar, o risco principal seria subir credenciais ou arquivos de state para o repositório público, ou criar recursos com permissões excessivas (como RDS publicamente acessível). A revisão manual de cada `plan` foi a camada de segurança mais importante do processo.

A evolução Git → Docker → Terraform → Módulos preparou para usar IA com responsabilidade porque cada camada não pode conter erros silenciosos: o Git expõe o histórico, o Docker falha no build se algo estiver errado, o Terraform mostra o plan antes de aplicar. Essa cadeia de validações explícitas criou o hábito de revisar antes de executar — que é exatamente o que deve ser feito com código gerado por IA. Uma frase que resume bem: a IA acelera a escrita, mas a responsabilidade pela revisão é sempre do desenvolvedor.

