library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.all;

entity asym_bram_tdp is
    generic (
        WIDTHA      : integer := 4;
        ADDRWIDTHA  : integer := 10;
        WIDTHB      : integer := 16;
        ADDRWIDTHB  : integer := 8;
        READLATA    : integer range 1 to 2 := 1;
        READLATB    : integer range 1 to 2 := 1;
        INIT        : bit_vector := X""
    );
    port (
        clkA   : in  std_logic;
        clkB   : in  std_logic;
        enA    : in  std_logic;
        enB    : in  std_logic;
        weA    : in  std_logic;
        weB    : in  std_logic;
        addrA  : in  std_logic_vector(ADDRWIDTHA-1 downto 0);
        addrB  : in  std_logic_vector(ADDRWIDTHB-1 downto 0);
        diA    : in  std_logic_vector(WIDTHA-1 downto 0);
        diB    : in  std_logic_vector(WIDTHB-1 downto 0);
        doA    : out std_logic_vector(WIDTHA-1 downto 0);
        doB    : out std_logic_vector(WIDTHB-1 downto 0)
    );
end asym_bram_tdp;

architecture intel of asym_bram_tdp is
    component altsyncram
        generic (
            OPERATION_MODE                     : string;
            WIDTH_A                            : natural;
            WIDTHAD_A                          : natural;
            NUMWORDS_A                         : natural;
            WIDTH_B                            : natural;
            WIDTHAD_B                          : natural;
            NUMWORDS_B                         : natural;
            OUTDATA_REG_A                      : string;
            OUTDATA_REG_B                      : string;
            ADDRESS_REG_B                      : string;
            READ_DURING_WRITE_MODE_MIXED_PORTS : string;
            READ_DURING_WRITE_MODE_PORT_A      : string;
            READ_DURING_WRITE_MODE_PORT_B      : string;
            CLOCK_ENABLE_INPUT_A               : string;
            CLOCK_ENABLE_INPUT_B               : string;
            CLOCK_ENABLE_OUTPUT_A              : string;
            CLOCK_ENABLE_OUTPUT_B              : string;
            RAM_BLOCK_TYPE                     : string;
            WIDTH_BYTEENA_A                    : natural;
            WIDTH_BYTEENA_B                    : natural
        );
        port (
            wren_a      : in  std_logic := '0';
            rden_a      : in  std_logic := '1';
            wren_b      : in  std_logic := '0';
            rden_b      : in  std_logic := '1';
            data_a      : in  std_logic_vector(WIDTHA-1 downto 0);
            data_b      : in  std_logic_vector(WIDTHB-1 downto 0);
            address_a   : in  std_logic_vector(ADDRWIDTHA-1 downto 0);
            address_b   : in  std_logic_vector(ADDRWIDTHB-1 downto 0);
            clock0      : in  std_logic := '1';
            clock1      : in  std_logic := '1';
            clocken0    : in  std_logic := '1';
            clocken1    : in  std_logic := '1';
            clocken2    : in  std_logic := '1';
            clocken3    : in  std_logic := '1';
            aclr0       : in  std_logic := '0';
            aclr1       : in  std_logic := '0';
            addressstall_a : in std_logic := '0';
            addressstall_b : in std_logic := '0';
            byteena_a   : in  std_logic_vector(0 downto 0) := "1";
            byteena_b   : in  std_logic_vector(0 downto 0) := "1";
            q_a         : out std_logic_vector(WIDTHA-1 downto 0);
            q_b         : out std_logic_vector(WIDTHB-1 downto 0)
        );
    end component;

    function reg_mode_a(lat : integer) return string is
    begin
        if lat = 2 then
            return "CLOCK0";
        else
            return "UNREGISTERED";
        end if;
    end function;

    function reg_mode_b(lat : integer) return string is
    begin
        if lat = 2 then
            return "CLOCK1";
        else
            return "UNREGISTERED";
        end if;
    end function;

begin

    ram_inst : altsyncram
        generic map (
            OPERATION_MODE                     => "BIDIR_DUAL_PORT",
            WIDTH_A                            => WIDTHA,
            WIDTHAD_A                          => ADDRWIDTHA,
            NUMWORDS_A                         => 2**ADDRWIDTHA,
            WIDTH_B                            => WIDTHB,
            WIDTHAD_B                          => ADDRWIDTHB,
            NUMWORDS_B                         => 2**ADDRWIDTHB,
            OUTDATA_REG_A                      => reg_mode_a(READLATA),
            OUTDATA_REG_B                      => reg_mode_b(READLATB),
            ADDRESS_REG_B                      => "CLOCK1",
            READ_DURING_WRITE_MODE_MIXED_PORTS => "DONT_CARE",
            READ_DURING_WRITE_MODE_PORT_A      => "DONT_CARE",
            READ_DURING_WRITE_MODE_PORT_B      => "DONT_CARE",
            CLOCK_ENABLE_INPUT_A               => "NORMAL",
            CLOCK_ENABLE_INPUT_B               => "NORMAL",
            CLOCK_ENABLE_OUTPUT_A              => "NORMAL",
            CLOCK_ENABLE_OUTPUT_B              => "NORMAL",
            RAM_BLOCK_TYPE                     => "AUTO",
            WIDTH_BYTEENA_A                    => 1,
            WIDTH_BYTEENA_B                    => 1
        )
        port map (
            wren_a         => weA and enA,
            rden_a         => enA,
            wren_b         => weB and enB,
            rden_b         => enB,
            data_a         => diA,
            data_b         => diB,
            address_a      => addrA,
            address_b      => addrB,
            clock0         => clkA,
            clock1         => clkB,
            clocken0       => '1',
            clocken1       => '1',
            clocken2       => '1',
            clocken3       => '1',
            aclr0          => '0',
            aclr1          => '0',
            addressstall_a => '0',
            addressstall_b => '0',
            byteena_a      => "1",
            byteena_b      => "1",
            q_a            => doA,
            q_b            => doB
        );

end intel;