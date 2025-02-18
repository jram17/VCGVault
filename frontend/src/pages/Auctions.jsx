import axios from 'axios';
import ListAuction from '@/components/ListAuction/ListAuction';
import { useEffect, useState } from 'react';

function Auctions() {
  const [auctions, setAuctions] = useState([]);
  const [isLoading, setisLoading] = useState(true);

  useEffect(() => {
    const fetchAuctionDetails = async () => {
      try {
        const response = await axios.get('/auctions');
        setAuctions(response.data);
      } catch (error) {
        console.error(error);
      } finally {
        setisLoading(false);
      }
    };
    fetchAuctionDetails();
  }, []);

  if (isLoading)
    return <div className="text-center text-xl text-gray-600">Loading...</div>;

  return (
    <div className="p-8  min-h-screen">
      <h1 className="text-[#002B5B] font-semibold text-3xl mb-6">Auctions</h1>
      {auctions.length > 0 ? (
        <ListAuction auctions={auctions} />
      ) : (
        <div className="text-gray-500 italic">No auctions available...</div>
      )}
    </div>
  );
}

export default Auctions;
