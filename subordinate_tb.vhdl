library ieee;
use ieee.std_logic_1164.all;

library std;
use std.env.finish;

entity subordinate_tb is
    generic (
        C_S_AXI_DATA_WIDTH : integer := 32;
        C_S_AXI_ADDR_WIDTH : integer := 4
    );
end subordinate_tb;

architecture arch of subordinate_tb is
    constant T : time := 20 ns;

    signal S_AXI_ACLK : std_logic;
    signal S_AXI_ARESETN : std_logic;
    signal S_AXI_AWADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_AWPROT : std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : std_logic;
    signal S_AXI_AWREADY : std_logic;
    signal S_AXI_WDATA : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_WSTRB : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    signal S_AXI_WVALID : std_logic;
    signal S_AXI_WREADY : std_logic;
    signal S_AXI_BRESP : std_logic_vector(1 downto 0);
    signal S_AXI_BVALID : std_logic;
    signal S_AXI_BREADY : std_logic;
    signal S_AXI_ARADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_ARPROT : std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : std_logic;
    signal S_AXI_ARREADY : std_logic;
    signal S_AXI_RDATA : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_RRESP : std_logic_vector(1 downto 0);
    signal S_AXI_RVALID : std_logic;
    signal S_AXI_RREADY : std_logic;
begin
    S : entity work.subordinate port map (
        S_AXI_ACLK => S_AXI_ACLK,
        S_AXI_ARESETN => S_AXI_ARESETN,
        S_AXI_AWADDR => S_AXI_AWADDR,
        S_AXI_AWPROT => S_AXI_AWPROT,
        S_AXI_AWVALID => S_AXI_AWVALID,
        S_AXI_AWREADY => S_AXI_AWREADY,
        S_AXI_WDATA => S_AXI_WDATA,
        S_AXI_WSTRB => S_AXI_WSTRB,
        S_AXI_WVALID => S_AXI_WVALID,
        S_AXI_WREADY => S_AXI_WREADY,
        S_AXI_BRESP => S_AXI_BRESP,
        S_AXI_BVALID => S_AXI_BVALID,
        S_AXI_BREADY => S_AXI_BREADY,
        S_AXI_ARADDR => S_AXI_ARADDR,
        S_AXI_ARPROT => S_AXI_ARPROT,
        S_AXI_ARVALID => S_AXI_ARVALID,
        S_AXI_ARREADY => S_AXI_ARREADY,
        S_AXI_RDATA => S_AXI_RDATA,
        S_AXI_RRESP => S_AXI_RRESP,
        S_AXI_RVALID => S_AXI_RVALID,
        S_AXI_RREADY => S_AXI_RREADY
    );

    process
    begin
        S_AXI_ACLK <= '0';
        wait for T/2;
        S_AXI_ACLK <= '1';
        wait for T/2;
    end process;

    process
    begin
        -- Reset

        S_AXI_ARESETN <= '0';
        S_AXI_AWVALID <= '0';
        S_AXI_AWPROT <= b"000";
        S_AXI_WVALID <= '0';
        S_AXI_BREADY <= '0';
        S_AXI_ARVALID <= '0';
        S_AXI_ARPROT <= b"000";
        S_AXI_RREADY <= '0';
        wait for T;

        assert(S_AXI_AWREADY = '0' and S_AXI_WREADY = '0');

        S_AXI_ARESETN <= '1';

        -- Write

        S_AXI_AWADDR <= b"0100";
        S_AXI_WSTRB <= b"1111";
        S_AXI_AWVALID <= '1';
        S_AXI_WDATA <= b"01010101010101010101010101010101";
        S_AXI_WVALID <= '1';
        wait for T;

        assert(S_AXI_AWREADY = '1' and S_AXI_WREADY = '1');

        wait for T;

        assert(S_AXI_AWREADY = '0' and S_AXI_WREADY = '0');

        S_AXI_AWVALID <= '0';
        S_AXI_WVALID <= '0';

        assert(S_AXI_BVALID = '1' and S_AXI_BRESP = b"00");
        S_AXI_BREADY <= '1';

        wait for T;

        assert(S_AXI_BVALID = '0');
        S_AXI_BREADY <= '0';

        -- Read

        S_AXI_ARADDR <= b"0100";
        S_AXI_ARVALID <= '1';
        wait for T;

        assert(S_AXI_ARREADY = '0');
        assert(S_AXI_RVALID = '1');
        assert(S_AXI_RDATA = b"01010101010101010101010101010101");

        S_AXI_RREADY <= '1';
        wait for T;
        assert(S_AXI_RVALID = '0');

        -- Finish

        wait for 2*T;
        finish;
    end process;
end arch;
