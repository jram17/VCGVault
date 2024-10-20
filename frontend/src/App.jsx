import {
  createBrowserRouter,
  createRoutesFromElements,
  Route,
  RouterProvider,
} from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { setAddress } from './redux/slice/AddressSlice';

import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import Home from './pages/Home';
import Layout from './components/Layout';
import CreateAuction from './pages/CreateAuction';
const router = createBrowserRouter(
  createRoutesFromElements(
    <Route path="/" element={<Layout />}>
      <Route index element={<Home />} />
      <Route path="/create-auction" element={<CreateAuction />} />
    </Route>
  )
);

function App() {
  const dispatch = useDispatch();
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const _initialize = async (selectedAddress) => {
    dispatch(setAddress(selectedAddress));
    // Add your initialization logic here
  };
  const _stopPollingData = () => {
    // Add your logic to stop polling data here
  };
  const _resetState = () => {
    dispatch(setAddress(null));
    // Add your logic to reset the state here
  };
  const _checkNetwork = async () => {
    // Add your network checking logic here
  };
  const _connectWallet = async () => {
    if (window.ethereum) {
      const [selectedAddress] = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });
      await _checkNetwork();
      await _initialize(selectedAddress);
      const provider = await new ethers.providers.Web3Provider(window.ethereum);
      setProvider(provider);
      const signer = provider.getSigner();
      setSigner(signer);
      window.ethereum.on('accountsChanged', ([newAddress]) => {
        _stopPollingData();
        if (newAddress === undefined) {
          return _resetState();
        }
        _initialize(newAddress);
      });
    }
  };
  useEffect(() => {
    _connectWallet();
  }, []);
  return <RouterProvider router={router} />;
}

export default App;
