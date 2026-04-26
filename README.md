# Controlador VGA 640x480 - FPGA (Cyclone IV)

## 1. Arquitetura e Função dos Arquivos Principais

    vga_pll.v (Gerador de Clock): Arquivo instanciado via MegaWizard/ALTPLL. Ele recebe o clock bruto de 50 MHz da placa (Pino Y2) e realiza a divisão/multiplicação via hardware para gerar exatamente 25.175 MHz, que é a frequência exigida pelo padrão VGA para 60Hz.

    vga_sync.v (Controlador de Varredura / Core Logic): O "cérebro" do monitor. Contém os contadores de varredura horizontal (pixel_x) e vertical (pixel_y). Baseado na contagem do clock de 25 MHz, ele gera os pulsos físicos de hsync e vsync, e também a trava de segurança video_on (que garante que as cores só sejam enviadas na área visível da tela, evitando distorções no retorno do canhão).

    top_vga.v (Módulo Top-Level / Placa-Mãe): O arquivo principal do projeto (que será gravado no chip). Ele atua como roteador: instancia o vga_pll e o vga_sync, conecta os sinais internos aos pinos físicos do cabo VGA e contém a lógica de cores (ex: desenhar um quadrado verde em uma tela cinza baseado nas coordenadas X e Y).

    tb_vga_sync.v (Testbench / Ambiente de Simulação): Arquivo exclusivo para validação virtual. Ele não é sintetizado para a placa. Ele gera um clock simulado e estímulos de reset para o vga_sync.v, permitindo debugar a matemática dos pulsos e contadores via ModelSim antes de gravar o hardware.

## 2. Comandos para Simulação (ModelSim Testbench)

    Abra o ModelSim e navegue até a pasta do projeto via terminal interno (Transcript):
    Tcl

    cd /caminho/para/sua/pasta/do/projeto

    Execute o bloco de comandos abaixo no Transcript para criar a biblioteca de trabalho, compilar os arquivos de simulação, invocar os gráficos e rodar o tempo de teste:
    Tcl

    # Cria diretório virtual de trabalho
    vlib work

    # Compila o controlador e o seu testbench
    vlog vga_sync.v tb_vga_sync.v

    # Inicia a simulação com visibilidade total de variáveis (+acc)
    vsim -voptargs="+acc" work.tb_vga_sync

    # Adiciona os sinais vitais na tela de ondas (Waveform)
    add wave -divider "Estimulos"
    add wave sim:/tb_vga_sync/clk_25mhz
    add wave sim:/tb_vga_sync/rst

    add wave -divider "Sincronismo"
    add wave sim:/tb_vga_sync/uut/hsync
    add wave sim:/tb_vga_sync/uut/vsync
    add wave sim:/tb_vga_sync/uut/video_on

    add wave -divider "Coordenadas (Decimal)"
    add wave -radix unsigned sim:/tb_vga_sync/uut/pixel_x
    add wave -radix unsigned sim:/tb_vga_sync/uut/pixel_y

    # Executa a simulação e ajusta o zoom na tela
    run -all
    wave zoom full
    
<img width="1060" height="460" alt="image" src="https://github.com/user-attachments/assets/a949be18-ca37-43b9-89d8-c85c975ade76" />

## 3. Resultados Esperados (Homologação da Varredura)

Ao rodar o Testbench, você deve analisar o gráfico gerado (Waveform) em busca destes comportamentos para garantir que o padrão VESA foi respeitado:

    Contadores Limites:

        O sinal pixel_x deve contar linearmente de 0 até 799. Ao bater 799, deve zerar.
        O sinal pixel_y deve incrementar +1 apenas no momento em que o pixel_x zera. Ele deve contar de 0 até 524 e, em seguida, zerar.
        
    Janela de Vídeo (video_on):

        O sinal video_on atua como um firewall de cor (1 = Ligado, 0 = Escuro).
        Ele deve cair para 0 no exato milissegundo em que o sinal pixel_x atingir 640 (início do H-Blanking) ou quando pixel_y atingir 480 (início do V-Blanking)

    Pulsos de Sincronismo (hsync e vsync):

        O sinal hsync passa a maior parte do tempo em estado lógico Alto (1). Ele deve apresentar um pulso Baixo (0) estritamente entre a contagem pixel_x 656 e 752.
        O sinal vsync também é ativo em estado lógico Alto (1). Ele deve apresentar um pulso Baixo (0) estritamente entre as linhas pixel_y 490 e 492.
        
## 4. Como Abrir o Projeto no Quartus (Síntese e Gravação)

### Para compilar o projeto completo e realizar a atribuição dos pinos físicos para a placa DE2-115, você não deve abrir os arquivos .v individualmente. Utilize o arquivo de projeto do Quartus.

    Abra o software Intel Quartus Prime.
    Na barra de menus superior, vá em File > Open Project... (ou use o atalho Ctrl+J).
    Navegue até o diretório do repositório.
    Selecione o arquivo top_vga.qpf (Quartus Project File) e clique em Open.
    Isso carregará toda a hierarquia do projeto, as configurações do chip Cyclone IV selecionado (EP4CE115F29C7) e as atribuições de pinos (Pin Planner) salvas no arquivo .qsf.
