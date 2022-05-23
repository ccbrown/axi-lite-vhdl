library ieee;
use ieee.std_logic_1164.all;

entity subordinate is
    generic (
        C_S_AXI_DATA_WIDTH : integer := 32;
        C_S_AXI_ADDR_WIDTH : integer := 4
    );

    port (
        S_AXI_ACLK : in std_logic;
        S_AXI_ARESETN : in std_logic;
        S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID : in std_logic;
        S_AXI_WREADY : out std_logic;
        S_AXI_BRESP : out std_logic_vector(1 downto 0);
        S_AXI_BVALID : out std_logic;
        S_AXI_BREADY : in std_logic;
        S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP : out std_logic_vector(1 downto 0);
        S_AXI_RVALID : out std_logic;
        S_AXI_RREADY : in std_logic
    );
end subordinate;

architecture arch of subordinate is
    signal axi_awaddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_wready : std_logic;
    signal axi_bresp : std_logic_vector(1 downto 0) := b"00";
    signal axi_bvalid : std_logic := '0';
    signal axi_araddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_arready : std_logic;
    signal axi_rdata : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal axi_rresp : std_logic_vector(1 downto 0) := b"00";
    signal axi_rvalid : std_logic := '0';

    signal r0 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal r1 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal r2 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal r3 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

    signal should_write : std_logic;
    signal should_read : std_logic;

    signal read_data : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
begin
    S_AXI_AWREADY <= axi_wready;
    S_AXI_WREADY <= axi_wready;
    S_AXI_BRESP <= axi_bresp;
    S_AXI_BVALID <= axi_bvalid;
    S_AXI_ARREADY <= axi_arready;
    S_AXI_RDATA <= axi_rdata;
    S_AXI_RRESP <= axi_rresp;
    S_AXI_RVALID <= axi_rvalid;

    should_write <= axi_wready and S_AXI_WVALID and axi_wready and S_AXI_AWVALID;
    should_read <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);
    axi_arready <= not S_AXI_RVALID;
    axi_awaddr <= S_AXI_AWADDR;
    axi_araddr <= S_AXI_ARADDR;

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                axi_wready <= '0';
            else
                axi_wready <= not axi_wready and (S_AXI_AWVALID and S_AXI_WVALID) and (not S_AXI_BVALID or S_AXI_BREADY);
            end if;
        end if;                   
    end process; 

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                axi_bvalid  <= '0';
                axi_bresp   <= "00";
            else
                if (should_write = '1') then
                    axi_bvalid <= '1';
                elsif (S_AXI_BREADY = '1') then
                    axi_bvalid <= '0';
                end if;
            end if;
        end if;                   
    end process; 

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                axi_rvalid <= '0';
                axi_rresp <= "00";
            else
                if (should_read = '1') then
                    axi_rvalid <= '1';
                elsif (S_AXI_RREADY = '1') then
                    axi_rvalid <= '0';
                end if;
            end if;
        end if;                   
    end process; 

    process (S_AXI_ACLK)
        variable dest_register :std_logic_vector(1 downto 0);
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                r0 <= (others => '0');
                r1 <= (others => '0');
                r2 <= (others => '0');
                r3 <= (others => '0');
            else
                dest_register := axi_awaddr(3 downto 2);
                if (should_write = '1') then
                    case dest_register is
                        when b"00" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                                if ( S_AXI_WSTRB(byte_index) = '1' ) then
                                    r0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        when b"01" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                                if ( S_AXI_WSTRB(byte_index) = '1' ) then
                                    r1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        when b"10" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                                if ( S_AXI_WSTRB(byte_index) = '1' ) then
                                    r2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        when b"11" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                                if ( S_AXI_WSTRB(byte_index) = '1' ) then
                                    r3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        when others =>
                            r0 <= r0;
                            r1 <= r1;
                            r2 <= r2;
                            r3 <= r3;
                    end case;
                end if;
            end if;
        end if;                   
    end process; 

    process (r0, r1, r2, r3, axi_araddr, S_AXI_ARESETN, should_read)
        variable loc_addr :std_logic_vector(1 downto 0);
    begin
        loc_addr := axi_araddr(3 downto 2);
        case loc_addr is
            when b"00" =>
                read_data <= r0;
            when b"01" =>
                read_data <= r1;
            when b"10" =>
                read_data <= r2;
            when b"11" =>
                read_data <= r3;
            when others =>
                read_data <= (others => '0');
        end case;
    end process; 

    process (S_AXI_ACLK) is
    begin
      if (rising_edge (S_AXI_ACLK)) then
        if (S_AXI_ARESETN = '0') then
          axi_rdata <= (others => '0');
        else
          if (should_read = '1') then
              axi_rdata <= read_data;
          end if;   
        end if;
      end if;
    end process;
end arch;
