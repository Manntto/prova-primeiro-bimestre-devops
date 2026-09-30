# Relatório do Processo — Prova do Primeiro Bimestre

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Disciplina:** DevOps — 2026.2  
**Ferramenta de IA utilizada:** Kiro (Spec-Driven Development)

---

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

A construção da API de Reservas da TechNova seguiu uma ordem que não foi aleatória: cada etapa dependia da anterior para fazer sentido. Comecei pelo Git (Aula 01) porque qualquer projeto sem versionamento está construído sobre areia. Criei o repositório público no GitHub, defini o `.gitignore` já no primeiro commit — isso foi importante para garantir que nenhum arquivo sensível como `.env`, `.tfstate` ou `.pem` fosse parar no repositório por acidente. Usei Conventional Commits desde o início (`chore:`, `feat:`, `docs:`, `fix:`) e trabalhei com feature branches, fazendo merge com `--no-ff` para que o histórico mostrasse o fluxo real de desenvolvimento.

Com o repositório estruturado, passei para a aplicação (Aula 01 — Docker). Criei a API Node.js com Express implementando o CRUD completo de reservas: POST, GET, GET/:id, PUT, DELETE e o endpoint `/health`. A persistência dos dados foi feita diretamente no PostgreSQL usando a biblioteca `pg`, sem nenhum dado em memória. Só depois de ter a aplicação funcionando é que criei o Dockerfile — um multi-stage build com `node:20-alpine`, instalando apenas as dependências de produção no stage final e executando com um usuário não-root por segurança.

O Docker Compose (Aula 02) foi o próximo passo natural: queria um ambiente local completo subindo com um único comando. Configurei o serviço `db` com PostgreSQL 15, volume nomeado para persistência, healthcheck com `pg_isready`, e o serviço `api` com `depends_on: condition: service_healthy` — a API só sobe depois que o banco estiver pronto. Tudo em uma rede bridge customizada chamada `reservas-net`.

Antes de partir para a AWS, criei o backend de remote state (Aula 06) — e aprendi que isso precisa ser feito antes de qualquer `terraform init` no projeto principal. Provisionei o bucket S3 `tfstate-reservas-1120245` com versionamento e encriptação AES256, e a tabela DynamoDB `tflock-reservas-1120245` para locking. Só depois disso configurei o `backend "s3"` no `providers.tf` do projeto principal.

Com o backend pronto, criei os quatro módulos Terraform (Aula 06): `vpc`, `security-group`, `ec2` e `rds`. A VPC (Aulas 03 e 04) foi a base: 10.0.0.0/16 com duas subnets públicas e duas privadas em us-east-1a e us-east-1b, Internet Gateway e Route Table para as subnets públicas. O módulo de Security Group (Aula 04) implementou o princípio do menor privilégio: a EC2 expõe as portas 22 e 3000, e o RDS aceita conexões na porta 5432 apenas a partir do Security Group da EC2. O módulo RDS (Aula 05) criou o PostgreSQL 15 nas subnets privadas com `publicly_accessible = false` e `storage_encrypted = true`. O módulo EC2 usou o `LabInstanceProfile` em vez de criar credenciais IAM próprias — restrição do Learner Lab que aprendi a respeitar.

A composição entre módulos (Aula 06) foi onde tudo se conectou: o output `vpc_id` alimentou o módulo de security group, os `private_subnet_ids` foram para o módulo RDS, e o `host` do RDS foi passado diretamente para o userdata da EC2. A IA como copiloto (Aulas 02 e 07) esteve presente em todas as etapas, mas cada arquivo gerado foi revisado e ajustado antes de ser aplicado.

---

## Questão 2 — O Processo com IA como Copiloto

Utilizei o **Kiro** como ferramenta de IA durante todo o desenvolvimento. O Kiro opera em modo de desenvolvimento guiado, o que significou que as interações foram contextuais — eu descrevia o que precisava construir e o Kiro gerava os arquivos diretamente no repositório, sem precisar copiar e colar código de uma janela para outra.

As partes onde o Kiro economizou mais tempo foram a estrutura inicial dos módulos Terraform e o boilerplate da API Node.js. Criar um módulo com `main.tf`, `variables.tf` e `outputs.tf` do zero é repetitivo e sujeito a erros de digitação — o Kiro gerou todos os quatro módulos de forma consistente, com os tipos corretos de variáveis, outputs bem nomeados e tags padronizadas em todos os recursos.

Porém, houve momentos em que o código gerado precisou de correção. O primeiro problema foi com o provider AWS 5.x no backend S3: o Kiro gerou o `aws_s3_bucket` corretamente, mas o Learner Lab bloqueia a chamada `s3:GetBucketObjectLockConfiguration` via Service Control Policy da organização — algo que nenhuma documentação padrão menciona. O apply quebrou no primeiro recurso e precisei diagnosticar o erro, entender a restrição e resolver via CLI. O segundo problema foram os caracteres especiais (travessão `—`) nas descriptions dos Security Groups — a AWS só aceita ASCII puro, e o Kiro usou caracteres tipográficos que causaram erro na criação. O terceiro foi a senha do RDS contendo `@`, que é caractere inválido para o PostgreSQL no RDS.

Esses três problemas não foram falhas graves, mas foram importantes: me forçaram a ler as mensagens de erro com atenção, entender o que estava acontecendo na AWS e corrigi-los com conhecimento real, não só tentativa e erro. Se tivesse aceitado o código sem revisar o plan, teria aplicado uma senha inválida diretamente no banco e levado mais tempo para encontrar o problema.

Comparando com fazer manualmente: estimo que o Kiro economizou cerca de 4 a 5 horas de trabalho, principalmente na escrita dos módulos Terraform, do userdata.sh e da API completa. Por outro lado, a IA não tem como saber as restrições específicas de um ambiente como o AWS Academy Learner Lab — esse conhecimento precisou vir de mim, das aulas e dos erros que apareceram durante o processo.

---

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

A arquitetura AWS provisionada segue um padrão clássico de separação entre camadas públicas e privadas. A EC2 foi colocada na subnet pública porque precisa de IP público para receber requisições externas na porta 3000. O RDS foi colocado nas subnets privadas porque um banco de dados nunca deve ser diretamente acessível pela internet — a flag `publicly_accessible = false` garante isso no nível da AWS, e o Security Group garante no nível de rede: a única origem que pode conectar na porta 5432 é o próprio Security Group da EC2.

Esse modelo segue o princípio do menor privilégio: cada recurso tem acesso apenas ao que precisa, nada a mais. A EC2 pode receber SSH (22) e requisições da API (3000). O RDS só pode receber conexões PostgreSQL (5432) vindas da EC2. Não há regra que permita acesso direto ao banco de qualquer IP externo.

O uso do `LabRole` e do `LabInstanceProfile` foi uma das principais adaptações necessárias para o ambiente do AWS Academy. Em um ambiente real, criaríamos uma IAM Role específica com as permissões mínimas necessárias. No Learner Lab, a criação de IAM users, groups ou roles é bloqueada por policy organizacional. A solução foi usar a role pré-existente `LabRole` para as operações Terraform (via credenciais temporárias) e o `LabInstanceProfile` associado à EC2 — isso permite que a instância se comunique com serviços AWS sem precisar de credenciais hardcoded no código.

As credenciais temporárias do Learner Lab trazem um desafio prático importante: elas expiram a cada sessão (geralmente em poucas horas). Isso significa que qualquer `terraform apply` que demore mais que a sessão atual vai falhar com `ExpiredToken`. A solução é reiniciar o Lab e atualizar o `~/.aws/credentials` antes de continuar. Em um ambiente real com credenciais de longa duração isso não seria um problema, mas no contexto do Lab é algo que precisa ser gerenciado ativamente.

Outra restrição específica do Lab foi o bloqueio de `s3:GetBucketObjectLockConfiguration` via SCP — o provider Terraform 5.x tenta ler essa configuração ao gerenciar buckets S3, e o Lab nega a chamada. A solução foi configurar o bucket via AWS CLI diretamente, o que é inclusive a abordagem recomendada pela própria documentação do Terraform para o bucket de remote state.

---

## Questão 4 — Validação e Responsabilidade

Antes de cada `terraform apply`, apliquei um checklist de validação que foi se tornando mais rigoroso conforme o projeto crescia. O primeiro passo sempre foi `terraform validate`, que verifica erros de sintaxe e referências inválidas entre módulos. O segundo foi `terraform plan`, que mostrou exatamente quais recursos seriam criados, modificados ou destruídos — li o output completo antes de confirmar qualquer apply.

Além da validação técnica, revisei pontos específicos de segurança antes de aplicar: confirmei que `publicly_accessible = false` e `storage_encrypted = true` estavam presentes no módulo RDS; verifiquei que o Security Group do RDS aceitava conexões apenas do SG da EC2 e não de `0.0.0.0/0`; confirmei que `iam_instance_profile = "LabInstanceProfile"` estava correto na EC2; e verifiquei que todos os arquivos sensíveis estavam no `.gitignore` antes de qualquer push.

Se tivesse aceitado o código da IA sem revisar, os erros encontrados durante este projeto teriam causado problemas maiores: uma senha inválida no RDS teria passado pelo plan mas falhado no apply, deixando recursos parcialmente criados no estado do Terraform — um cenário mais difícil de resolver do que simplesmente corrigir a variável antes de aplicar. Os caracteres especiais nos Security Groups teriam causado o mesmo problema.

A evolução Git → Docker → Compose → Terraform → Módulos foi fundamental para desenvolver esse senso crítico. Cada camada ensina um tipo diferente de responsabilidade: o Git ensina que cada mudança deve ser intencional e rastreável; o Docker ensina que o ambiente de execução importa tanto quanto o código; o Compose ensina que dependências entre serviços precisam ser declaradas explicitamente; o Terraform ensina que infraestrutura tem estado e que mudanças podem ser destrutivas. Quando cheguei aos módulos e à IA como copiloto, já tinha o vocabulário necessário para entender o que o código gerado estava fazendo — e para identificar quando algo estava errado.

Usar IA com responsabilidade não significa desconfiar de tudo que ela gera. Significa ter o conhecimento para saber o que revisar, o que testar e o que questionar. As aulas do bimestre construíram exatamente esse conhecimento.

---

*Relatório escrito com base na experiência real de desenvolvimento da prova, com suporte do Kiro como ferramenta de IA.*
