import React, { createContext, useEffect, useState } from "react";
import { AppShell, BackgroundImage, MantineProvider } from "@mantine/core";
import { HeaderAction } from "./components/Header";
import { TripsGrid } from "./components/Landing";
import { Route, Routes } from "react-router-dom";
import { AllTripsGrid } from "./components/Explore";
import { Support } from "./components/Support";
import { Login } from "./components/Login";
import { Register } from "./components/Register";

export const UserContext = createContext({});

function App() {
  const [userSession, setUserSession] = useState(true);

  useEffect(() => {
    const fetchUserAuth = async () => {
      try {
        const res = await fetch("/api/isAuth");
        setUserSession(await res.json());
      } catch (error) {
        console.error("There was an error fetch auth", error);
        return;
      }
    };
    fetchUserAuth();
  }, []);

  return (
    <UserContext.Provider value={userSession}>
      <MantineProvider
        withGlobalStyles
        withNormalizeCSS
        theme={{
          colorScheme: "dark",
          fontFamily: "Open Sans, sans serif",
          headings: { fontFamily: "Space Groteske, sans-serif" },
          colors: {
            dark: [
              "#FFFFFF",
              "#A6A7AB",
              "#909296",
              "#5C5F66",
              "#373A40",
              "#2C2E33",
              "#2C2E33",
              "#212121",
              "#212121",
              "#212121",
            ],
          },
        }}
      >
        <AppShell
          padding={0}
          header={<HeaderAction />}
          styles={(theme) => ({
            main: {
              backgroundColor:
                theme.colorScheme === "dark"
                  ? theme.colors.dark[8]
                  : theme.colors.gray[0],
            },
          })}
        >
          <BackgroundImage
            src="bg.png"
            style={{
              background: "url(bg.png) no-repeat center center fixed",
              backgroundSize: "cover",
            }}
          >
            <Routes>
              <Route path="/" element={<TripsGrid />} />
              <Route path="/explore" element={<AllTripsGrid />} />
              <Route path="/support" element={<Support />} />
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
            </Routes>
          </BackgroundImage>
        </AppShell>
      </MantineProvider>
    </UserContext.Provider>
  );
}

export default App;
